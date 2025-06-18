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
    private let viewModel: ChatViewModel

    private let greetingLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        return label
    }()

    // MARK: - Init
    init(viewModel: ChatViewModel) {
        self.viewModel = viewModel
        self.chatID = viewModel.chatID
        self.otherUser = viewModel.otherUser
        self.currentUserID = viewModel.currentUserID
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.onMessagesUpdated = { [weak self] sections in
            guard let self = self else { return }
            self.tableView.reloadData()
            self.scrollToBottom(animated: false)
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Logout",
            style: .plain,
            target: self,
            action: #selector(didTapLogout)
        )
        
        setupViews()
        setupConstraints()
        viewModel.observeMessages()
        
        greetingLabel.textColor = .label
        greetingLabel.text = "Chatting with \(otherUser.name)"
        title = otherUser.name
    }

    // MARK: - Setup
    private func setupViews() {
        view.backgroundColor = .systemBackground
        
        greetingLabel.font = .boldSystemFont(ofSize: 24)
        greetingLabel.textAlignment = .center
        greetingLabel.textColor = .label
        view.addSubview(greetingLabel)
        
        tableView.backgroundColor = .clear
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ChatTableViewCell.self, forCellReuseIdentifier: "ChatTableViewCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        view.addSubview(tableView)
        
        messageInputBar.backgroundColor = .secondarySystemBackground
        textField.placeholder = "Type something..."
        sendButton.setTitle("Send", for: .normal)
        sendButton.setTitleColor(.systemBlue, for: .normal)
        sendButton.addTarget(self, action: #selector(didTapSend), for: .touchUpInside)
        messageInputBar.addSubview(textField)
        messageInputBar.addSubview(sendButton)
        view.addSubview(messageInputBar)
    }

    private func setupConstraints() {
        [greetingLabel, tableView, messageInputBar, textField, sendButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            greetingLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            greetingLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
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
        viewModel.logout { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("🚪 Logged out successfully")
                    let welcomeVC = WelcomeViewController()
                    let nav = UINavigationController(rootViewController: welcomeVC)
                    if let sceneDelegate = self?.view.window?.windowScene?.delegate as? SceneDelegate {
                        sceneDelegate.window?.rootViewController = nav
                    }
                case .failure(let error):
                    let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(alert, animated: true)
                }
            }
        }
    }

    @objc private func didTapSend() {
        guard let text = textField.text, !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        viewModel.sendMessage(text)
        textField.text = ""
        scrollToBottom()
    }

    // MARK: - Helpers
    private func scrollToBottom(animated: Bool = true) {
        guard !viewModel.messageSections.isEmpty else { return }
        
        let lastSection = viewModel.messageSections.count - 1
        let lastRow = viewModel.messageSections[lastSection].messages.count - 1
        
        if lastRow >= 0 {
            let indexPath = IndexPath(row: lastRow, section: lastSection)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
        }
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
        return viewModel.messageSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.messageSections[section].messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = viewModel.messageSections[indexPath.section]
        let message = section.messages[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatTableViewCell", for: indexPath) as! ChatTableViewCell
        
        let isCurrentUser = message.senderID == viewModel.currentUserID
        var showSender = true
        if indexPath.row > 0 {
            let previousMessage = section.messages[indexPath.row - 1]
            showSender = previousMessage.senderID != message.senderID
        }
        
        cell.configure(with: message, isCurrentUser: isCurrentUser, showSender: showSender)
        return cell
    }
}
