import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let ws = scene as? UIWindowScene else { return }
        let w = UIWindow(windowScene: ws)
        w.rootViewController = HostViewController()
        w.backgroundColor = .black
        w.makeKeyAndVisible()
        window = w
        OverlayWindowManager.shared.install(in: ws)
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        OverlayWindowManager.shared.ensureVisible()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        OverlayWindowManager.shared.pause()
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        OverlayWindowManager.shared.resume()
    }
}
