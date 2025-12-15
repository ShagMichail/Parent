//
//  AppDelegate.swift.swift
//  Parent
//
//  Created by Михаил Шаговитов on 17.11.2025.
//

import UIKit
import CloudKit
import BackgroundTasks
import UserNotifications
import os.log
import DeviceActivity

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.laborato.checkCommands", using: nil) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
        
        application.registerForRemoteNotifications()
        return true
    }
    
    // 2. Обработка фоновой задачи (вызывается системой)
    func handleAppRefresh(task: BGAppRefreshTask) {
        // Планируем следующую проверку
        scheduleNextCheck()
        
        task.expirationHandler = {
            print("🛑 Время на фоновую задачу истекло")
        }
        
        Task {
            await CommandSyncService.shared.checkPendingCommands()
            task.setTaskCompleted(success: true)
        }
    }
    
    // 3. Планировщик следующей проверки
    func scheduleNextCheck() {
        let request = BGAppRefreshTaskRequest(identifier: "com.laborato.checkCommands")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 1 * 60) // Попросить разбудить через 15 мин
        
        do {
            try BGTaskScheduler.shared.submit(request)
            print("⏰ Фоновая проверка запланирована")
        } catch {
            print("❌ Не удалось запланировать фон: \(error)")
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        // Преобразуем словарь userInfo в объект уведомления CloudKit
        guard let notification = CKNotification(fromRemoteNotificationDictionary: userInfo) else {
            completionHandler(.noData)
            return
        }
        
        print("🔔 AppDelegate: Получен пуш с ID: \(notification.subscriptionID ?? "unknown")")
        
        // 1. ЛОГИКА ПРИГЛАШЕНИЙ
        if notification.subscriptionID?.starts(with: "invitation-accepted-") == true {
            if let queryNotification = notification as? CKQueryNotification,
               let recordFields = queryNotification.recordFields {
                
                let childID = recordFields["childUserRecordID"] as? String ?? ""
                let childName = recordFields["childName"] as? String ?? ""
                
                NotificationCenter.default.post(
                    name: .invitationAcceptedByChild,
                    object: nil,
                    userInfo: ["childUserRecordID": childID, "childName": childName]
                )
            }
            completionHandler(.newData)
            return
        }
        
        // 2. ЛОГИКА ПРИНЯТИЯ КОМАНД
        if notification.subscriptionID?.starts(with: "commands-for-user-") == true {
            print("🔔 AppDelegate: Команда обработана расширением.")
            
            NotificationCenter.default.post(name: NSNotification.Name("RefreshUI"), object: nil)
            
            completionHandler(.newData)
            return
        }
        
        // 3. ОБНОВЛЕНИЯ СТАТУСА (ДЛЯ РОДИТЕЛЯ)
        if notification.subscriptionID?.starts(with: "command-updates-") == true {
            print("🔔 [Parent] Получено обновление статуса команды!")
            
            if let queryNotification = notification as? CKQueryNotification,
               let recordFields = queryNotification.recordFields,
               let recordID = queryNotification.recordID {
                
                let status = recordFields["status"] as? String ?? ""
                let commandName = recordFields["commandName"] as? String ?? ""
                let childID = recordFields["targetChildID"] as? String ?? ""
                
                NotificationCenter.default.post(
                    name: NSNotification.Name("CommandStatusUpdated"),
                    object: nil,
                    userInfo: [
                        "recordID": recordID,
                        "status": status,
                        "commandName": commandName,
                        "childID": childID
                    ]
                )
            }
            completionHandler(.newData)
            return
        }

        // 4. ОБНОВЛЕНИЕ РАСПИСАНИЙ
        if notification.subscriptionID?.starts(with: "focus-schedules-") == true {
            print("🔔 [AppDelegate] Получен пуш на обновление расписания. Запускаем синхронизацию...")
            
            var bgTaskID: UIBackgroundTaskIdentifier = .invalid
            bgTaskID = application.beginBackgroundTask(withName: "SyncDeviceActivitySchedules") {
                application.endBackgroundTask(bgTaskID)
                bgTaskID = .invalid
            }
            
            Task {
                await FocusScheduleManager.shared.syncWithDeviceActivityFromCache()
                print("✅ [AppDelegate] Синхронизация расписаний завершена.")
                completionHandler(.newData)
                if bgTaskID != .invalid {
                    application.endBackgroundTask(bgTaskID)
                }
            }
            return
        }
        
        completionHandler(.noData)
    }
}

extension Notification.Name {
    static let invitationAcceptedByChild = Notification.Name("invitationAcceptedByChild")
    static let commandUpdated = Notification.Name("CommandStatusUpdated") // Новое уведомление
}
