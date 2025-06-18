# 📱 ChatByMadaan

ChatByMadaan is a lightweight 1:1 messaging app built for iOS using UIKit, MVVM architecture, and Firebase for backend services. 
It enables authenticated users to search and chat with other registered users in real-time.

---

## 🚀 Features

- 🔐 User Registration & Login (Firebase Auth)
- 📇 Contacts Page with Live Search
- 💬 Real-Time 1:1 Messaging with Firestore
- 🗨️ Dynamic Chat UI with Sender Differentiation
- 📜 Message Grouping by Day
- 🧠 MVVM Architecture (Model-View-ViewModel)
- 🌐 Firestore-based chat and user data storage
- 👋 Auth State Persistence
- 🧼 Logout functionality

---

## 🛠 Tech Stack

- **iOS**: UIKit, AutoLayout (programmatic UI)
- **Architecture**: MVVM
- **Backend**: Firebase Auth, Firebase Firestore
- **Languages**: Swift 5+

---

## 📂 Project Structure

```bash
ChatByMadaan/
│
├── App/                             # AppDelegate, SceneDelegate
│
├── Models/                          # Data Models (User, Message, MessageSection)
│
├── Views/
│   ├── Cells/                       # Custom UITableViewCells like ChatTableViewCell
│   └── Screens/
│       ├── Auth/                    # LoginViewController, RegisterViewController
│       ├── Contacts/                # ContactsViewController
│       └── Chat/                    # ChatViewController
│
├── ViewModels/
│   ├── Auth/                        # LoginViewModel, RegisterViewModel
│   ├── Contacts/                    # ContactsViewModel
│   └── Chat/                        # ChatViewModel
│
├── Resources/                       # Assets, launch images, and other static resources
│
├── Firebase/                        # Firebase rules (configured via console)
│
├── ChatByMadaan.xcodeproj           # Xcode project file
└── README.md
```

---

## 🔧 Setup Instructions

### 1. Clone the Repo
```bash
git clone https://github.com/ankitmadaan-nottaken/ChatByMadaan.git
cd ChatByMadaan
```

### 2. Open the Project
Open `ChatByMadaan.xcodeproj` in Xcode.

### 3. Install Dependencies
Ensure Firebase dependencies are installed via **Swift Package Manager**.

### 4. Configure Firebase
- Create a Firebase project in the Firebase Console
- Enable **Email/Password Authentication**
- Create a **Firestore database** in Test mode
- Download the `GoogleService-Info.plist` file
- Drag it into your Xcode project

### 5. Set Firestore Rules
Paste the following in the Firebase Console under Firestore > Rules:

```js
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function isSignedIn() {
      return request.auth != null;
    }

    match /users/{userId} {
      allow read: if isSignedIn();
      allow write: if isSignedIn() && request.auth.uid == userId;
    }

    match /chats/{chatId} {
      allow read, write: if isSignedIn();
      match /messages/{messageId} {
        allow read, write: if isSignedIn();
      }
      match /typingStatus/{userId} {
        allow write: if isSignedIn() && request.auth.uid == userId;
        allow read: if isSignedIn();
      }
    }
  }
}
```

---

## 🧪 Testing Tips

- Register at least 2 users through the app.
- Log in as one user, go to **Contacts**, and select another user to start chatting.
- Messages are grouped by date and aligned left/right depending on the sender.
- Use **Xcode logs** to debug message status or Firebase sync issues.

---

## 🧼 Known Limitations

- No profile photos or read receipts yet
- No push notifications
- Group chat not supported (only 1:1)

---

## 🙌 Contributions

Pull requests welcome! Feel free to fork and submit PRs. For major changes, please open an issue first to discuss improvements or new features.

---
