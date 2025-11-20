//
//  AppDelegate.swift.swift
//  Parent
//
//  Created by Михаил Шаговитов on 17.11.2025.
//

import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Запрашиваем разрешение на отправку уведомлений (даже тихих)
        application.registerForRemoteNotifications()
        return true
    }
    
    // Этот метод вызывается, когда приходит push-уведомление
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        // Передаем уведомление нашему менеджеру
        CloudKitManager.shared.handleRemoteNotification(userInfo: userInfo)
        
        completionHandler(.newData)
    }
}
