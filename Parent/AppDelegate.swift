//
//  AppDelegate.swift.swift
//  Parent
//
//  Created by Михаил Шаговитов on 17.11.2025.
//

import UIKit
import CloudKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        application.registerForRemoteNotifications()
        
        if let userInfo = launchOptions?[.remoteNotification] as? [AnyHashable: Any] {
            print("🚀 Приложение было запущено из-за тихого push-уведомления!")
            routeNotification(userInfo: userInfo)
        }
        
        return true
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print(" AppDelegate: Получено удаленное уведомление (приложение было активно или в фоне).")
        routeNotification(userInfo: userInfo)
        completionHandler(.newData)
    }

    private func routeNotification(userInfo: [AnyHashable: Any]) {
        if let notification = CKNotification(fromRemoteNotificationDictionary: userInfo),
           let queryNotification = notification as? CKQueryNotification {
            
            if queryNotification.subscriptionID?.hasPrefix("invitation-") == true {
                CloudKitManager.shared.handleRemoteNotificationForInvitation(userInfo: userInfo)
            } else if queryNotification.subscriptionID?.hasPrefix("commands-for-user-") == true {
                CloudKitManager.shared.handleRemoteNotificationForCommand(userInfo: userInfo)
            }
        }
    }
}
