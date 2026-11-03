//
//  AppDelegate.swift
//  pSTaRT
//
//  Created by Kurt Frey on 03.11.26.
//  Copyright © 2026 Kurt Frey. All rights reserved.
//


import UIKit

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Cold start: the app was not running.
        if let shortcutItem = options.shortcutItem {
            AppRouter.shared.handle(shortcutItem)
        }
        let configuration = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        configuration.delegateClass = SceneDelegate.self
        return configuration
    }
}

final class SceneDelegate: NSObject, UIWindowSceneDelegate {
    // App was in the background.
    func windowScene(_ windowScene: UIWindowScene,
                     performActionFor shortcutItem: UIApplicationShortcutItem,
                     completionHandler: @escaping (Bool) -> Void) {
        completionHandler(AppRouter.shared.handle(shortcutItem))
    }
}
