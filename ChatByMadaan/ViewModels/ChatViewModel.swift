import Foundation
import FirebaseAuth
import FirebaseFirestore

class ChatViewModel {

    // MARK: - Properties
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    var chatID: String
    var otherUser: User
    var currentUserID: String

    var messageSections: [MessageSection] = [] {
        didSet {
            onMessagesUpdated?(messageSections)
        }
    }

    // MARK: - Callbacks
    var onMessagesUpdated: (([MessageSection]) -> Void)?
    var onError: ((String) -> Void)?

    // MARK: - Init
    init(chatID: String, otherUser: User) {
        self.chatID = chatID
        self.otherUser = otherUser
        self.currentUserID = Auth.auth().currentUser?.uid ?? ""
    }

    deinit {
        listener?.remove()
    }

    // MARK: - Fetch Messages
    func observeMessages() {
        listener = db.collection("chats")
            .document(chatID)
            .collection("messages")
            .order(by: "timestamp")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }

                guard let documents = snapshot?.documents else {
                    self.onError?("No messages found.")
                    return
                }

                let messages: [Message] = documents.compactMap { doc in
                    let data = doc.data()
                    guard let text = data["message"] as? String,
                          let senderID = data["senderID"] as? String else { return nil }

                    let timestamp = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                    let statusRaw = data["status"] as? String ?? "sent"
                    let status = MessageStatus(rawValue: statusRaw) ?? .sent

                    return Message(id: doc.documentID, senderID: senderID, text: text, timestamp: timestamp, status: status)
                }

                let grouped = Dictionary(grouping: messages) { message in
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    return formatter.string(from: message.timestamp)
                }

                let sections = grouped.map { dateStr, messages in
                    let title = self.formatDateLabel(from: dateStr)
                    let sorted = messages.sorted { $0.timestamp < $1.timestamp }
                    return MessageSection(title: title, messages: sorted)
                }.sorted { $0.messages.first!.timestamp < $1.messages.first!.timestamp }

                self.messageSections = sections
            }
    }

    // MARK: - Send Message
    func sendMessage(_ text: String, completion: ((Bool) -> Void)? = nil) {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else {
            completion?(false)
            return
        }

        let data: [String: Any] = [
            "message": text,
            "senderID": currentUserID,
            "timestamp": FieldValue.serverTimestamp(),
            "status": MessageStatus.sent.rawValue
        ]

        db.collection("chats")
            .document(chatID)
            .collection("messages")
            .addDocument(data: data) { error in
                if let error = error {
                    self.onError?("Failed to send message: \(error.localizedDescription)")
                    completion?(false)
                } else {
                    completion?(true)
                }
            }
    }

    // MARK: - Helpers
    private func formatDateLabel(from dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: dateString) else { return dateString }

        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    func logout(completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }

}
