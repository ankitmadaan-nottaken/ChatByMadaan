import Foundation
import FirebaseAuth
import FirebaseFirestore

class ContactsViewModel {
    private let db = Firestore.firestore()
    private var currentUserID: String {
        Auth.auth().currentUser?.uid ?? ""
    }
    
    var users: [User] = []
    var filteredUsers: [User] = []
    
    var onUsersUpdated: (() -> Void)?
    var onError: ((String) -> Void)?
    
    func fetchUsers() {
        print("📡 Fetching users from Firestore...")
        db.collection("users").getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ Failed to fetch users: \(error.localizedDescription)")
                self.onError?("Failed to fetch users")
                return
            }
            
            guard let documents = snapshot?.documents else {
                self.users = []
                self.filteredUsers = []
                self.onUsersUpdated?()
                return
            }
            
            self.users = documents.compactMap { doc in
                let data = doc.data()
                let id = doc.documentID
                guard id != self.currentUserID,
                      let name = data["name"] as? String,
                      let email = data["email"] as? String else { return nil }
                return User(id: id, name: name, email: email)
            }
            
            self.filteredUsers = self.users
            print("✅ Found \(self.filteredUsers.count) contacts")
            self.onUsersUpdated?()
        }
    }
    
    func filterUsers(by searchText: String) {
        let query = searchText.lowercased()
        if query.isEmpty {
            filteredUsers = users
        } else {
            filteredUsers = users.filter {
                $0.name.lowercased().contains(query) ||
                $0.email.lowercased().contains(query)
            }
        }
        onUsersUpdated?()
    }
    
    func chatID(with otherUserID: String) -> String {
        [currentUserID, otherUserID].sorted().joined(separator: "_")
    }
    
    func ensureChatExists(with user: User, completion: @escaping (String) -> Void) {
        let chatID = chatID(with: user.id)
        let chatDocRef = db.collection("chats").document(chatID)
        
        chatDocRef.getDocument { snapshot, error in
            if let snapshot = snapshot, !snapshot.exists {
                chatDocRef.setData([
                    "participants": [self.currentUserID, user.id],
                    "createdAt": FieldValue.serverTimestamp()
                ]) { error in
                    if let error = error {
                        print("❌ Failed to create chat: \(error.localizedDescription)")
                    } else {
                        print("✅ Chat created with ID: \(chatID)")
                    }
                    completion(chatID)
                }
            } else {
                completion(chatID)
            }
        }
    }
}
