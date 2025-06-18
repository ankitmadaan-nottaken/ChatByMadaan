import UIKit
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        let rootVC: UIViewController

        if Auth.auth().currentUser != nil {
            print("🔐 User already logged in, showing ContactsViewController")
            rootVC = ContactsViewController()
        } else {
            print("🚪 No user session, showing WelcomeViewController")
            rootVC = WelcomeViewController()
        }

        let navController = UINavigationController(rootViewController: rootVC)
        window.rootViewController = navController
        window.makeKeyAndVisible()
        self.window = window
    }
}
