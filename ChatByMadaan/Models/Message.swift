import Foundation
import FirebaseFirestore

enum MessageStatus: String, Codable {
    case sent
    case delivered
    case seen
}
struct Message {
    let id: String
    let senderID: String
    let text: String
    let timestamp: Date
    let status: MessageStatus

    init(id: String, senderID: String, text: String, timestamp: Date, status: MessageStatus) {
        self.id = id
        self.senderID = senderID
        self.text = text
        self.timestamp = timestamp
        self.status = status
    }
}
