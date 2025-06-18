import Foundation
import FirebaseAuth
import FirebaseFirestore

class RegisterViewModel {
    
    func register(name: String, email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let uid = result?.user.uid else {
                completion(.failure(NSError(domain: "Missing UID", code: 0, userInfo: nil)))
                return
            }
            
            let db = Firestore.firestore()
            db.collection("users").document(uid).setData([
                "id": uid,
                "name": name,
                "email": email
            ]) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    }
}
