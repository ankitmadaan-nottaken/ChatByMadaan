//  ChatViewController.swift
//  ChatByMadaan

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // MARK: - Properties
    private let db = Firestore.firestore()
    private let chatID: String
    private let otherUser: User
    private let currentUserID: String

    private var messageSections: [MessageSection] = []

    private let tableView = UITableView()
    private let messageInputBar = UIView()
    private let textField = UITextField()
    private let sendButton = UIButton()
    private let greetingLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        return label
    }()

    // MARK: - Init
    init(chatID: String, otherUser: User) {
        self.chatID = chatID
        self.otherUser = otherUser
        self.currentUserID = Auth.auth().currentUser?.uid ?? ""
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = otherUser.name
        greetingLabel.text = "Chatting with \(otherUser.name)"
        greetingLabel.textColor = .label

        view.addSubview(greetingLabel)
        greetingLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            greetingLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            greetingLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        setupViews()
        setupConstraints()
        observeMessages()
    }

    // MARK: - Setup
    private func setupViews() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Logout",
            style: .plain,
            target: self,
            action: #selector(didTapLogout)
        )

        view.backgroundColor = .systemBackground
        tableView.backgroundColor = .clear

        view.addSubview(tableView)
        view.addSubview(messageInputBar)
        messageInputBar.addSubview(textField)
        messageInputBar.addSubview(sendButton)

        tableView.register(ChatTableViewCell.self, forCellReuseIdentifier: "ChatTableViewCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60

        messageInputBar.backgroundColor = .secondarySystemBackground
        textField.placeholder = "Type something..."
        sendButton.setTitle("Send", for: .normal)
        sendButton.setTitleColor(.systemBlue, for: .normal)
        sendButton.addTarget(self, action: #selector(didTapSend), for: .touchUpInside)
    }

    private func setupConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        messageInputBar.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        sendButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: greetingLabel.bottomAnchor, constant: 8),
            tableView.bottomAnchor.constraint(equalTo: messageInputBar.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            messageInputBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            messageInputBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            messageInputBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            messageInputBar.heightAnchor.constraint(equalToConstant: 50),

            textField.leadingAnchor.constraint(equalTo: messageInputBar.leadingAnchor, constant: 12),
            textField.centerYAnchor.constraint(equalTo: messageInputBar.centerYAnchor),
            textField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8),

            sendButton.trailingAnchor.constraint(equalTo: messageInputBar.trailingAnchor, constant: -12),
            sendButton.centerYAnchor.constraint(equalTo: messageInputBar.centerYAnchor)
        ])
    }

    // MARK: - Actions
    @objc private func didTapLogout() {
        do {
            try Auth.auth().signOut()
            let welcomeVC = WelcomeViewController()
            let nav = UINavigationController(rootViewController: welcomeVC)
            if let sceneDelegate = view.window?.windowScene?.delegate as? SceneDelegate {
                sceneDelegate.window?.rootViewController = nav
            }
        } catch {
            let alert = UIAlertController(title: "Error", message: "Logout failed.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }

    @objc private func didTapSend() {
        guard let text = textField.text, !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        let messageData: [String: Any] = [
            "message": text,
            "senderID": currentUserID,
            "timestamp": FieldValue.serverTimestamp()
        ]

        db.collection("chats")
            .document(chatID)
            .collection("messages")
            .addDocument(data: messageData) { [weak self] error in
                if error == nil {
                    self?.textField.text = ""
                    self?.scrollToBottom()
                }
            }
    }

    // MARK: - Firestore Listener
    func observeMessages() {
        db.collection("chats")
            .document(chatID)
            .collection("messages")
            .order(by: "timestamp")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self, let documents = snapshot?.documents else { return }

                let messages: [Message] = documents.compactMap { doc in
                    let data = doc.data()
                    guard let text = data["message"] as? String,
                          let senderID = data["senderID"] as? String else {
                        return nil
                    }
                    let timestamp = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                    let statusRaw = (data["status"] as? String) ?? "sent"
                    let status = MessageStatus(rawValue: statusRaw) ?? .sent
                    return Message(id: doc.documentID, senderID: senderID, text: text, timestamp: timestamp, status: status)
                }

                let grouped = Dictionary(grouping: messages) { message in
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    return formatter.string(from: message.timestamp)
                }

                let sections = grouped.map { dateString, messages in
                    let title = self.formatDateLabel(from: dateString)
                    let sortedMessages = messages.sorted { $0.timestamp < $1.timestamp }
                    return MessageSection(title: title, messages: sortedMessages)
                }

                self.messageSections = sections.sorted { $0.messages.first!.timestamp < $1.messages.first!.timestamp }

                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.scrollToBottom(animated: false)
                }
            }
    }

    // MARK: - Helpers
    func scrollToBottom(animated: Bool = true) {
        guard let lastSection = messageSections.indices.last else { return }
        let lastRow = messageSections[lastSection].messages.count - 1
        guard lastRow >= 0 else { return }

        let indexPath = IndexPath(row: lastRow, section: lastSection)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
    }

    private func formatDateLabel(from dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: dateString) else {
            return dateString
        }
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    // MARK: - UITableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return messageSections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageSections[section].messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = messageSections[indexPath.section]
        let message = section.messages[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatTableViewCell", for: indexPath) as! ChatTableViewCell
        let isCurrentUser = message.senderID == currentUserID

        var showSender = true
        if indexPath.row > 0 {
            let previousMessage = section.messages[indexPath.row - 1]
            showSender = previousMessage.senderID != message.senderID
        }

        cell.configure(with: message, isCurrentUser: isCurrentUser, showSender: showSender)
        return cell
    }
}
