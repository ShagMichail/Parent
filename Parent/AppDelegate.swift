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

class AppDelegate: NSObject, UIApplicationDelegate {
    
    private let logger = Logger(subsystem: "ParentalControl", category: "Background")
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        application.registerForRemoteNotifications()
        
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "\(Bundle.main.bundleIdentifier!).priority-command-check", using: nil) { task in
            self.handlePriorityCommandCheck(task: task as! BGAppRefreshTask)
        }
        
        if AuthenticationManager.shared.userRole == .child {
            logger.info("🚀 Запускаем усиленный мониторинг команд для ребенка")
            self.startEnhancedMonitoring()
        }
        
        if let userInfo = launchOptions?[.remoteNotification] as? [AnyHashable: Any] {
            logger.info("Приложение запущено из push-уведомления")
            self.handlePriorityCommandProcessing(userInfo: userInfo)
        }
        
        return true
    }
    
    private func startEnhancedMonitoring() {
        self.performImmediateCommandCheck()
        self.schedulePriorityBackgroundChecks()
        self.setupActivityHandlers()
    }
    

    private func performImmediateCommandCheck() {
        logger.info("Выполняем немедленную проверку команд")
        
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            await CloudKitManager.shared.fetchNewCommands()
            await CloudKitManager.shared.processPendingCommands()
        }
    }
    
    private func handlePriorityCommandCheck(task: BGAppRefreshTask) {
        logger.info("🔄 ПРИОРИТЕТНАЯ фоновая проверка запущена")
        task.expirationHandler = {
            self.logger.warning("⏰ Приоритетная проверка прервана")
            task.setTaskCompleted(success: false)
        }
        
        let semaphore = DispatchSemaphore(value: 0)
        var success = false
        
        Task {
            defer {
                semaphore.signal()
            }
            
            do {
                self.logger.info("Начинаем приоритетную проверку команд")
                await CloudKitManager.shared.fetchNewCommands()
                await CloudKitManager.shared.processPendingCommands()
                success = true
                self.logger.info("✅ Приоритетная проверка завершена успешно")
            } catch {
                self.logger.error("❌ Ошибка приоритетной проверки: \(error)")
            }
        }
        
        let result = semaphore.wait(timeout: .now() + 20)
        if result == .timedOut {
            logger.error("⏰ Таймаут приоритетной проверки")
            task.setTaskCompleted(success: false)
        } else {
            task.setTaskCompleted(success: success)
        }
        
        self.schedulePriorityBackgroundChecks()
    }
    
    // ✅ ПЛАНИРОВАНИЕ ПРИОРИТЕТНЫХ ПРОВЕРОК
    private func schedulePriorityBackgroundChecks() {
        let request = BGAppRefreshTaskRequest(identifier: "\(Bundle.main.bundleIdentifier!).priority-command-check")
        
        #if DEBUG
        request.earliestBeginDate = Date(timeIntervalSinceNow: 3 * 60) // 3 минуты в debug
        #else
        request.earliestBeginDate = Date(timeIntervalSinceNow: 2 * 60) // 2 минуты в release
        #endif
        
        do {
            try BGTaskScheduler.shared.submit(request)
            logger.info("✅ Приоритетная проверка запланирована")
        } catch {
            logger.error("❌ Ошибка планирования: \(error)")
            DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
                self.schedulePriorityBackgroundChecks()
            }
        }
    }
    
    private func setupActivityHandlers() {
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main) { _ in
            self.logger.info("Приложение стало активным - проверяем команды")
            self.performImmediateCommandCheck()
        }
        
        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { _ in
            self.logger.info("Приложение переходит в foreground - проверяем команды")
            self.performImmediateCommandCheck()
        }
    }
    
    private func handlePriorityCommandProcessing(userInfo: [AnyHashable: Any]) {
        logger.info("Обрабатываем push-уведомление с высоким приоритетом")
        var backgroundTaskID: UIBackgroundTaskIdentifier?
        backgroundTaskID = UIApplication.shared.beginBackgroundTask {
            if let taskID = backgroundTaskID {
                UIApplication.shared.endBackgroundTask(taskID)
            }
        }
        
        Task {
            defer {
                if let taskID = backgroundTaskID {
                    UIApplication.shared.endBackgroundTask(taskID)
                }
            }
            
            if let notification = CKQueryNotification(fromRemoteNotificationDictionary: userInfo),
               notification.queryNotificationReason == .recordCreated,
               let recordID = notification.recordID {
                
                do {
                    let record = try await CKContainer.default().publicCloudDatabase.record(for: recordID)
                    if let commandName = record["commandName"] as? String {
                        logger.info("Получена команда через push: \(commandName)")
                        await MainActor.run {
                            CloudKitManager.shared.commandExecutor?.executeCommand(name: commandName, recordID: recordID)
                        }
                    }
                } catch {
                    logger.error("Ошибка обработки push-команды: \(error)")
                }
            }
        }
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        logger.info("📡 System Background Fetch запущен")
        
        guard AuthenticationManager.shared.userRole == .child else {
            completionHandler(.noData)
            return
        }
        
        Task {
            do {
                await CloudKitManager.shared.quickCommandCheck()
                completionHandler(.newData)
            } catch {
                completionHandler(.failed)
            }
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        logger.info("Получено CloudKit push-уведомление")
        
        self.handlePriorityCommandProcessing(userInfo: userInfo)
        completionHandler(.newData)
    }
}
