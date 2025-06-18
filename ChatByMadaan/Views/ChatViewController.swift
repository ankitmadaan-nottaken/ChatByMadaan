
//  ChatViewController.swift
//  ChatByMadaan
//
//  Created by Ankit Madan on 6/11/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore


class ChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageSections[section].messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = messageSections[indexPath.section]
        let message = section.messages[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatTableViewCell", for: indexPath) as! ChatTableViewCell
        let currentUserID = Auth.auth().currentUser?.uid

        let isCurrentUser = message.senderID == currentUserID
                // Determine whether to show sender
        var showSender = true
        if indexPath.row > 0 {
            let previousMessage = section.messages[indexPath.row - 1]
            showSender = previousMessage.senderID != message.senderID
        }

        cell.configure(with: message, isCurrentUser: isCurrentUser, showSender: showSender)
        return cell
    }

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return messageSections.count
    }

    
    let db = Firestore.firestore()
    var messages: [Message] = []
    var chatID: String = "default_chat" // Replace with your actual chat ID logic

    var currentUserID: String?
    let tableView = UITableView()
    let messageInputBar = UIView()
    let textField = UITextField()
    let sendButton = UIButton()
    var messageSections: [MessageSection] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Logout",
            style: .plain,
            target: self,
            action: #selector(didTapLogout)
        )
        view.addSubview(greetingLabel)
        greetingLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            greetingLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            greetingLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        if let user = Auth.auth().currentUser {
            let name = user.displayName ?? user.email ?? "User"
            greetingLabel.textColor = .systemBlue
            greetingLabel.text = "👋 Welcome, \(name)!"
        }
        tableView.dataSource = self
        tableView.delegate = self

        
        setupViews()
        setupConstraints()
        print("👀 ChatViewController loaded")
        observeMessages()

    }
    let greetingLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        return label
    }()
    
    func setupViews() {
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
        
        // Customize
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
    
    func setupConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        messageInputBar.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Table View
            tableView.topAnchor.constraint(equalTo: greetingLabel.bottomAnchor, constant: 8),
            tableView.bottomAnchor.constraint(equalTo: messageInputBar.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            // Input Bar
            messageInputBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            messageInputBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            messageInputBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            messageInputBar.heightAnchor.constraint(equalToConstant: 50),
            
            // Text Field
            textField.leadingAnchor.constraint(equalTo: messageInputBar.leadingAnchor, constant: 12),
            textField.centerYAnchor.constraint(equalTo: messageInputBar.centerYAnchor),
            textField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8),
            
            // Send Button
            sendButton.trailingAnchor.constraint(equalTo: messageInputBar.trailingAnchor, constant: -12),
            sendButton.centerYAnchor.constraint(equalTo: messageInputBar.centerYAnchor)
        ])
    }
    
    @objc private func didTapLogout() {
        do {
            try Auth.auth().signOut()
            print("🚪 Logged out successfully")

            // Navigate back to Welcome screen
            let welcomeVC = WelcomeViewController()
            let nav = UINavigationController(rootViewController: welcomeVC)

            // Replace root view controller
            if let sceneDelegate = view.window?.windowScene?.delegate as? SceneDelegate {
                sceneDelegate.window?.rootViewController = nav
            }
        } catch {
            print("❌ Logout failed: \(error.localizedDescription)")
            let alert = UIAlertController(title: "Error", message: "Logout failed.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
    
    @objc private func didTapSend() {
        guard let text = textField.text, !text.trimmingCharacters(in: .whitespaces).isEmpty,
              let senderID = Auth.auth().currentUser?.uid else { return }

        let messageData: [String: Any] = [
            "message": text,
            "senderID": senderID,
            "timestamp": FieldValue.serverTimestamp()
        ]

        db.collection("chats")
            .document(chatID)
            .collection("messages")
            .addDocument(data: messageData) { [weak self] error in
                guard let self = self else { return }
                if let error = error {
                    print("❌ Failed to send message:", error.localizedDescription)
                } else {
                    print("✅ Message sent")
                    self.textField.text = ""
                    self.scrollToBottom()
                }
            }
    }
    
    func observeMessages() {
        print("📡 Setting up listener for messages...")
        
        db.collection("chats")
            .document(chatID)
            .collection("messages")
            .order(by: "timestamp")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                guard let documents = snapshot?.documents else {
                    print("⚠️ No documents found or error: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                print("📥 Received \(documents.count) messages")
                
                let messages: [Message] = documents.compactMap { doc -> Message? in
                    let data = doc.data()
                    
                    guard let text = data["message"] as? String,
                          let senderID = data["senderID"] as? String else {
                        return nil
                    }
                    
                    let timestamp = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                    let statusRaw = (data["status"] as? String) ?? "sent"
                    let status = MessageStatus(rawValue: statusRaw) ?? .sent
                    
                    print("📩 \(text) — status: \(status.rawValue)")
                    
                    return Message(
                        id: doc.documentID,
                        senderID: senderID,
                        text: text,
                        timestamp: timestamp,
                        status: status
                    )
                }
                
                // Break up the expression to avoid compile time errors
                let grouped = Dictionary(grouping: messages) { message in
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    return formatter.string(from: message.timestamp)
                }
                
                let sections: [MessageSection] = grouped.map { dateString, messages in
                    let title = self.formatDateLabel(from: dateString)
                    let sortedMessages = messages.sorted { $0.timestamp < $1.timestamp }
                    return MessageSection(title: title, messages: sortedMessages)
                }
                
                self.messageSections = sections.sorted {
                    $0.messages.first!.timestamp < $1.messages.first!.timestamp
                }
                
                DispatchQueue.main.async {
                    print("🔄 Reloading tableView with \(self.messageSections.count) sections")

                    self.tableView.reloadData()
                    self.scrollToBottom(animated: false)
                }
            }
    }
    
    func scrollToBottom(animated: Bool = true) {
        guard !messageSections.isEmpty else { return }

        let lastSection = messageSections.count - 1
        let lastRow = messageSections[lastSection].messages.count - 1

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
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }







}
