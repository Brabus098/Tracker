
//  SceneDelegate.swift

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
  
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
   
        var userDefaults = EnterSettingsUserDefaults()
        var startController = OnboardingViewController()
        startController.enterStatusDelegate = userDefaults
        window?.rootViewController = startController
        window?.makeKeyAndVisible()
    }
}

