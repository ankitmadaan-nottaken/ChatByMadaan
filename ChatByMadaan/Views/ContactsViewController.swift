import UIKit
import Firebase
import FirebaseAuth

class ContactsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating {
    
    private let tableView = UITableView()
    private var searchController = UISearchController(searchResultsController: nil)
    
    private var users: [User] = []
    private var filteredUsers: [User] = []
    var chatID: String!
    var otherUser: User!
    
    private var currentUserID: String {
        Auth.auth().currentUser?.uid ?? ""
    }
    
    private let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Contacts"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Logout",
            style: .plain,
            target: self,
            action: #selector(didTapLogout)
        )
        
        
        setupSearchController()
        setupTableView()
        fetchUsers()
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Contacts"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    private func setupTableView() {
        tableView.frame = view.bounds
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
    }
    
    private func fetchUsers() {
        db.collection("users").getDocuments { [weak self] snapshot, error in
            guard let self = self, let documents = snapshot?.documents else { return }
            
            self.users = documents.compactMap { doc in
                let data = doc.data()
                let id = doc.documentID
                guard id != self.currentUserID, // exclude self
                      let name = data["name"] as? String,
                      let email = data["email"] as? String else { return nil }
                return User(id: id, name: name, email: email)
            }
            print("📡 Current UserID: \(self.currentUserID)")
            print("📦 All Users: \(documents.map { $0.documentID })")

            
            self.filteredUsers = self.users
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = filteredUsers[indexPath.row].name
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedUser = filteredUsers[indexPath.row]
        let currentUserID = Auth.auth().currentUser?.uid ?? ""
        let chatID = [currentUserID, selectedUser.id].sorted().joined(separator: "_")
        
        let chatDocRef = db.collection("chats").document(chatID)
        
        chatDocRef.getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let snapshot = snapshot, !snapshot.exists {
                // 🔧 Create the chat document with participants
                chatDocRef.setData([
                    "participants": [currentUserID, selectedUser.id],
                    "createdAt": FieldValue.serverTimestamp()
                ]) { error in
                    if let error = error {
                        print("❌ Failed to create chat: \(error.localizedDescription)")
                        return
                    } else {
                        print("✅ Chat created with ID: \(chatID)")
                    }
                }
            }
            
            // ✅ Proceed to chat view
            let chatVC = ChatViewController(chatID: chatID, otherUser: selectedUser)
            self.navigationController?.pushViewController(chatVC, animated: true)
        }
    }
    
    
    // MARK: - UISearchResultsUpdating
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text?.lowercased() ?? ""
        if searchText.isEmpty {
            filteredUsers = users
        } else {
            filteredUsers = users.filter {
                $0.name.lowercased().contains(searchText) ||
                $0.email.lowercased().contains(searchText)
            }
        }
        tableView.reloadData()
    }
    @objc private func didTapLogout() {
        do {
            try Auth.auth().signOut()
            print("🚪 Logged out successfully")

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

}
