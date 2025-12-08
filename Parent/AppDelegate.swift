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

//class AppDelegate: NSObject, UIApplicationDelegate {
//    
//    private let logger = Logger(subsystem: "ParentalControl", category: "Background")
//    
//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
//        application.registerForRemoteNotifications()
//        
//        BGTaskScheduler.shared.register(forTaskWithIdentifier: "\(Bundle.main.bundleIdentifier!).priority-command-check", using: nil) { task in
//            self.handlePriorityCommandCheck(task: task as! BGAppRefreshTask)
//        }
//        
//        if AuthenticationManager.shared.userRole == .child {
//            logger.info("🚀 Запускаем усиленный мониторинг команд для ребенка")
//            self.startEnhancedMonitoring()
//        }
//        
//        if let userInfo = launchOptions?[.remoteNotification] as? [AnyHashable: Any] {
//            logger.info("Приложение запущено из push-уведомления")
//            self.handlePriorityCommandProcessing(userInfo: userInfo)
//        }
//        
//        return true
//    }
//    
//    private func startEnhancedMonitoring() {
//        self.performImmediateCommandCheck()
//        self.schedulePriorityBackgroundChecks()
//        self.setupActivityHandlers()
//    }
//    
//
//    private func performImmediateCommandCheck() {
//        logger.info("Выполняем немедленную проверку команд")
//        
//        Task {
//            try? await Task.sleep(nanoseconds: 2_000_000_000)
//            await CloudKitManager.shared.fetchNewCommands()
//            await CloudKitManager.shared.processPendingCommands()
//        }
//    }
//    
//    private func handlePriorityCommandCheck(task: BGAppRefreshTask) {
//        logger.info("🔄 ПРИОРИТЕТНАЯ фоновая проверка запущена")
//        task.expirationHandler = {
//            self.logger.warning("⏰ Приоритетная проверка прервана")
//            task.setTaskCompleted(success: false)
//        }
//        
//        let semaphore = DispatchSemaphore(value: 0)
//        var success = false
//        
//        Task {
//            defer {
//                semaphore.signal()
//            }
//            
//            do {
//                self.logger.info("Начинаем приоритетную проверку команд")
//                await CloudKitManager.shared.fetchNewCommands()
//                await CloudKitManager.shared.processPendingCommands()
//                success = true
//                self.logger.info("✅ Приоритетная проверка завершена успешно")
//            } catch {
//                self.logger.error("❌ Ошибка приоритетной проверки: \(error)")
//            }
//        }
//        
//        let result = semaphore.wait(timeout: .now() + 20)
//        if result == .timedOut {
//            logger.error("⏰ Таймаут приоритетной проверки")
//            task.setTaskCompleted(success: false)
//        } else {
//            task.setTaskCompleted(success: success)
//        }
//        
//        self.schedulePriorityBackgroundChecks()
//    }
//    
//    // ✅ ПЛАНИРОВАНИЕ ПРИОРИТЕТНЫХ ПРОВЕРОК
//    private func schedulePriorityBackgroundChecks() {
//        let request = BGAppRefreshTaskRequest(identifier: "\(Bundle.main.bundleIdentifier!).priority-command-check")
//        
//        #if DEBUG
//        request.earliestBeginDate = Date(timeIntervalSinceNow: 3 * 60) // 3 минуты в debug
//        #else
//        request.earliestBeginDate = Date(timeIntervalSinceNow: 2 * 60) // 2 минуты в release
//        #endif
//        
//        do {
//            try BGTaskScheduler.shared.submit(request)
//            logger.info("✅ Приоритетная проверка запланирована")
//        } catch {
//            logger.error("❌ Ошибка планирования: \(error)")
//            DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
//                self.schedulePriorityBackgroundChecks()
//            }
//        }
//    }
//    
//    private func setupActivityHandlers() {
//        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main) { _ in
//            self.logger.info("Приложение стало активным - проверяем команды")
//            self.performImmediateCommandCheck()
//        }
//        
//        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { _ in
//            self.logger.info("Приложение переходит в foreground - проверяем команды")
//            self.performImmediateCommandCheck()
//        }
//    }
//    
//    private func handlePriorityCommandProcessing(userInfo: [AnyHashable: Any]) {
//        logger.info("Обрабатываем push-уведомление с высоким приоритетом")
//        var backgroundTaskID: UIBackgroundTaskIdentifier?
//        backgroundTaskID = UIApplication.shared.beginBackgroundTask {
//            if let taskID = backgroundTaskID {
//                UIApplication.shared.endBackgroundTask(taskID)
//            }
//        }
//        
//        Task {
//            defer {
//                if let taskID = backgroundTaskID {
//                    UIApplication.shared.endBackgroundTask(taskID)
//                }
//            }
//            
//            if let notification = CKQueryNotification(fromRemoteNotificationDictionary: userInfo),
//               notification.queryNotificationReason == .recordCreated,
//               let recordID = notification.recordID {
//                
//                do {
//                    let record = try await CKContainer.default().publicCloudDatabase.record(for: recordID)
//                    if let commandName = record["commandName"] as? String {
//                        logger.info("Получена команда через push: \(commandName)")
//                        await MainActor.run {
//                            CloudKitManager.shared.commandExecutor?.executeCommand(name: commandName, recordID: recordID)
//                        }
//                    }
//                } catch {
//                    logger.error("Ошибка обработки push-команды: \(error)")
//                }
//            }
//        }
//    }
//    
//    private func routeCloudKitNotification(userInfo: [AnyHashable: Any]) {
//            
//            // Пытаемся распарсить уведомление как объект CloudKit.
//            guard let notification = CKQueryNotification(fromRemoteNotificationDictionary: userInfo) else {
//                logger.warning("⚠️ Получен push, но это не CKQueryNotification.")
//                return
//            }
//            
//            // Проверяем ID подписки, чтобы понять, что это за уведомление.
//            if notification.subscriptionID?.hasPrefix("invitation-") == true {
//                // --- ЭТО УВЕДОМЛЕНИЕ О ПРИГЛАШЕНИИ (ДЛЯ РОДИТЕЛЯ) ---
//                logger.info("➡️ Маршрутизация: Уведомление о принятии приглашения.")
//                CloudKitManager.shared.handleRemoteNotificationForInvitationAcceptance(userInfo: userInfo)
//                
//            } else if notification.subscriptionID?.hasPrefix("commands-for-user-") == true {
//                // --- ЭТО УВЕДОМЛЕНИЕ О КОМАНДЕ (ДЛЯ РЕБЕНКА) ---
//                logger.info("➡️ Маршрутизация: Уведомление о новой команде.")
//                
//                // Здесь мы НЕ исполняем команду напрямую. Мы "пинаем" DeviceActivityMonitor.
//                // Это самый надежный способ.
//                triggerImmediateDeviceActivityCheck()
//                
//            } else {
//                logger.warning("➡️ Маршрутизация: Неизвестный тип подписки: \(notification.subscriptionID ?? "nil")")
//            }
//        }
//        
//        /// Запускает короткий мониторинг, чтобы "разбудить" DeviceActivityMonitorExtension.
//        private func triggerImmediateDeviceActivityCheck() {
//            let center = DeviceActivityCenter()
//            
//            // Уникальное имя для мониторинга "по требованию".
//            let forceCheckActivityName = DeviceActivityName("force-check")
//            
//            // Расписание на 15 секунд, начиная с текущего момента.
//            let schedule = DeviceActivitySchedule(
//                intervalStart: DateComponents(second: 0),
//                intervalEnd: DateComponents(second: 15),
//                repeats: false
//            )
//            
//            do {
//                // "Пинаем" систему.
//                try center.startMonitoring(forceCheckActivityName, during: schedule)
//                logger.info("✅ Успешно запланирована немедленная проверка команд через DeviceActivityMonitor.")
//            } catch {
//                logger.error("❌ Не удалось запланировать немедленную проверку: \(error)")
//            }
//        }
//    
//    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
//        logger.info("📡 System Background Fetch запущен")
//        
//        guard AuthenticationManager.shared.userRole == .child else {
//            completionHandler(.noData)
//            return
//        }
//        
//        Task {
//            do {
//                await CloudKitManager.shared.quickCommandCheck()
//                completionHandler(.newData)
//            } catch {
//                completionHandler(.failed)
//            }
//        }
//    }
//    
//    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
//        logger.info("Получено CloudKit push-уведомление")
//        routeCloudKitNotification(userInfo: userInfo)
//        self.handlePriorityCommandProcessing(userInfo: userInfo)
//        completionHandler(.newData)
//    }
//}

// AppDelegate.swift

import UIKit
import DeviceActivity
import CloudKit
import os.log

class AppDelegate: NSObject, UIApplicationDelegate {
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "AppDelegate")
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        application.registerForRemoteNotifications()
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        // Преобразуем словарь userInfo в объект уведомления CloudKit
        guard let notification = CKNotification(fromRemoteNotificationDictionary: userInfo) else {
            completionHandler(.noData)
            return
        }
        
        print("🔔 AppDelegate: Получен пуш с ID: \(notification.subscriptionID ?? "unknown")")
        
        // 1. ЛОГИКА ПРИГЛАШЕНИЙ (было раньше)
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
        
        // 2. ЛОГИКА КОМАНД (НОВОЕ! Добавь это) 🛑
        if notification.subscriptionID?.starts(with: "commands-for-user-") == true {
            print("🔔 AppDelegate: Это команда для ребенка!")
            
            // Это уведомление о создании/изменении записи
            if let queryNotification = notification as? CKQueryNotification,
               let recordID = queryNotification.recordID {
                
                // Запускаем обработку команды в фоне
                Task {
                    await handleIncomingCommand(recordID: recordID)
                    completionHandler(.newData)
                }
            } else {
                completionHandler(.noData)
            }
            return
        }
        
        // 3. ОБНОВЛЕНИЯ СТАТУСА (ДЛЯ РОДИТЕЛЯ) - НОВОЕ!
        if notification.subscriptionID?.starts(with: "command-updates-") == true {
            print("🔔 [Parent] Получено обновление статуса команды!")
            
            if let queryNotification = notification as? CKQueryNotification,
               let recordFields = queryNotification.recordFields,
               let recordID = queryNotification.recordID {
                
                let status = recordFields["status"] as? String ?? ""
                let commandName = recordFields["commandName"] as? String ?? ""
                let childID = recordFields["targetChildID"] as? String ?? ""
                
                // Шлем уведомление внутри приложения, чтобы ViewModel услышала
                NotificationCenter.default.post(
                    name: NSNotification.Name("CommandStatusUpdated"),
                    object: nil,
                    userInfo: [
                        "recordID": recordID, // Передаем сам объект CKRecord.ID
                        "status": status,
                        "commandName": commandName,
                        "childID": childID
                    ]
                )
            }
            completionHandler(.newData)
            return
        }
        
        completionHandler(.noData)
    }
    
    // Вспомогательная функция для обработки команды (можно вынести в отдельный менеджер)
    private func handleIncomingCommand(recordID: CKRecord.ID) async {
        do {
            // 1. Скачиваем саму команду, чтобы понять, что делать
            let record = try await CloudKitManager.shared.publicDatabase.record(for: recordID)
            
            guard let commandName = record["commandName"] as? String else { return }
            print("🚀 AppDelegate: Пришла команда: \(commandName)")
            
            // 2. ТУТ ВЫПОЛНЯЕМ БЛОКИРОВКУ (FamilyControls)
            await MainActor.run {
                DeviceControlService.shared.executeLocalCommand(commandName)
            }
            // 3. Обновляем статус на .executed, чтобы родитель узнал
            try await CloudKitManager.shared.updateCommandStatus(recordID: recordID, status: .executed)
            print("✅ AppDelegate: Отчитались о выполнении")
            
        } catch {
            print("🚨 Ошибка обработки команды: \(error)")
        }
    }
}

extension Notification.Name {
    static let invitationAcceptedByChild = Notification.Name("invitationAcceptedByChild")
    static let commandUpdated = Notification.Name("CommandStatusUpdated") // Новое уведомление
}
