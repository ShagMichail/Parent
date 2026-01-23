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
                
                //                let recordName = recordFields["Name"] as? String ?? ""
                let childID = recordFields["childUserRecordID"] as? String ?? ""
                let childName = recordFields["childName"] as? String ?? ""
                let childGender = recordFields["childGender"] as? String ?? ""
                let childAppleID = recordFields["childAppleID"] as? String ?? ""
                
                NotificationCenter.default.post(
                    name: .invitationAcceptedByChild,
                    object: nil,
                    
                    userInfo: ["childUserRecordID": childID, "childName": childName, "childGender": childGender, "childAppleID": childAppleID]
                )
            }
            completionHandler(.newData)
            return
        }
        
        // 2. ЛОГИКА ПРИНЯТИЯ КОМАНД
        if notification.subscriptionID?.starts(with: "commands-for-user-") == true {
            if let ckInfo = userInfo["ck"] as? [String: Any],
               let query = ckInfo["qry"] as? [String: Any],
               let fields = query["af"] as? [String: Any],
               let commandName = fields["commandName"] as? String {
                
                // 📍 ЛОВИМ ТОЛЬКО ЛОКАЦИЮ
                if commandName == "request_location_update" {
                    print("📍 AppDelegate: Пришел запрос локации! Запускаем Background Task.")
                    
                    // Просим у системы время на работу
//                    var bgTaskID: UIBackgroundTaskIdentifier = .invalid
//                    bgTaskID = application.beginBackgroundTask(withName: "ForceLocationUpdate") {
//                        // Если время вышло
//                        application.endBackgroundTask(bgTaskID)
//                        bgTaskID = .invalid
//                    }
//                    
//                    // Запускаем обновление координат
//                    LocationManager.shared.forceSendStatus()
//                    
//                    // Даем системе понять, что мы обработали данные
//                    completionHandler(.newData)
//                    
//                    // Завершаем задачу чуть позже (даем пару секунд на отправку)
//                    DispatchQueue.global().asyncAfter(deadline: .now() + 10) {
//                        if bgTaskID != .invalid {
//                            application.endBackgroundTask(bgTaskID)
//                            bgTaskID = .invalid
//                        }
//                    }
//                    return
                    
                    print("🔔 AppDelegate: Определение локации пропустили (ее делает NSE). Просто обновляем UI.")
                    NotificationCenter.default.post(name: NSNotification.Name("RefreshUI"), object: nil)
                    completionHandler(.noData)
                    return
                }
                
                // 🛑 БЛОКИРОВКИ ИГНОРИРУЕМ
                if commandName == "block_all" || commandName == "unblock_all" {
                    print("🔔 AppDelegate: Блокировку пропустили (ее делает NSE). Просто обновляем UI.")
                    NotificationCenter.default.post(name: NSNotification.Name("RefreshUI"), object: nil)
                    completionHandler(.noData)
                    return
                }
            }
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
                FocusScheduleManager.shared.syncWithDeviceActivityFromCache()
                print("✅ [AppDelegate] Синхронизация расписаний завершена.")
                completionHandler(.newData)
                if bgTaskID != .invalid {
                    application.endBackgroundTask(bgTaskID)
                }
            }
            return
        }
        
        if notification.subscriptionID?.starts(with: "app-limits-updates-") == true {
            print("🔔 [AppDelegate] Пуш о лимитах уже обработан расширением.")
            completionHandler(.newData)
            return
        }
        
        if notification.subscriptionID?.starts(with: "app-blocks-updates-") == true {
            print("🔔 [AppDelegate] Пуш о блокировках уже обработан расширением.")
            completionHandler(.newData)
            return
        }
        
        if notification.subscriptionID?.starts(with: "web-blocks-updates-") == true {
            print("🔔 [AppDelegate] Пуш о web блокировках уже обработан расширением.")
            completionHandler(.newData)
            return
        }
        
        if notification.subscriptionID?.starts(with: "parent-notifications-subscription") == true {
            print("🔔 [Parent] Получено новое уведомление от ребенка из Push!")
            
            if let queryNotification = notification as? CKQueryNotification,
               let recordFields = queryNotification.recordFields,
               let recordID = queryNotification.recordID { 
                
                let type = recordFields["type"] as? String ?? ""
                let date = recordFields["date"] as? Date ?? Date()
                let childId = recordFields["childId"] as? String ?? ""
                let commandName = recordFields["commandName"] as? String ?? ""
                let commandStatus = recordFields["commandStatus"] as? String ?? ""
                
                NotificationCenter.default.post(
                    name: NSNotification.Name("ParentNotificationReceived"),
                    object: nil,
                    userInfo: [
                        "recordID": recordID.recordName,
                        "type": type,
                        "date": date,
                        "childId": childId,
                        "commandName": commandName,
                        "commandStatus": commandStatus
                    ]
                )
            }
            
            completionHandler(.newData)
            return
        }
        
        completionHandler(.noData)
    }
}

extension Notification.Name {
    static let invitationAcceptedByChild = Notification.Name("invitationAcceptedByChild")
    static let commandUpdated = Notification.Name("CommandStatusUpdated")
}
