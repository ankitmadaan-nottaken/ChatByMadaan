import Foundation

struct Chat: Codable, Identifiable {
    let id: String
    let participants: [String]    // userIDs of sender and receiver
    let lastMessage: String
    let lastUpdated: Date

    init(id: String, participants: [String], lastMessage: String, lastUpdated: Date = Date()) {
        self.id = id
        self.participants = participants
        self.lastMessage = lastMessage
        self.lastUpdated = lastUpdated
    }
}
