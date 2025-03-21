//
//  SceneDelegate.swift
//  ReadAloudDaily
//
//  Created by 권정근 on 3/17/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        let homeVC = UINavigationController(rootViewController: HomeViewController())
        window?.rootViewController = homeVC
        window?.makeKeyAndVisible()
    }
}

