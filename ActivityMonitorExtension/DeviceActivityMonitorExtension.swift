////
////  DeviceActivityMonitorExtension.swift
////  ActivityMonitorExtension
////
////  Created by Михаил Шаговитов on 03.12.2025.
////
//
//import DeviceActivity
//import ManagedSettings
//import CloudKit
//import os.log
//
//class DeviceActivityMonitorExtension: DeviceActivityMonitor {
//    let store = ManagedSettingsStore()
//    let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "ActivityMonitor")
//    
//    // Безопасный доступ к общему хранилищу
//    var sharedUserDefaults: UserDefaults? {
//        UserDefaults(suiteName: "group.com.laborato.test.Parent") // Убедитесь, что ID группы верный
//    }
//
//    /// Вызывается системой, когда начинается ЛЮБОЙ из отслеживаемых интервалов.
//    override func intervalDidStart(for activity: DeviceActivityName) {
//        super.intervalDidStart(for: activity)
//        logger.info("☀️ Интервал для '\(activity.rawValue)' начался.")
//        
//        Task {
//            // Выполняем проверку в любом случае
//            await checkForNewCommandsAndApplySettings()
//            
//            // Если это была ПЛАНОВАЯ проверка, планируем следующую
//            if activity == FREQUENT_CHECK_ACTIVITY_NAME {
//                scheduleNextDeviceActivityCheck()
//            }
//            
//            // Если это был запуск "по требованию", останавливаем его
//            if activity == FORCE_CHECK_ACTIVITY_NAME {
//                DeviceActivityCenter().stopMonitoring([activity])
//                logger.info("⏹️ Одноразовый мониторинг 'force-check' остановлен.")
//            }
//        }
//    }
//
//    /// Главная функция, которая делает всю работу в фоне.
//    private func checkForNewCommandsAndApplySettings() async {
//        // 1. Получаем ID ребенка из общего хранилища UserDefaults.
//        guard let childID = sharedUserDefaults?.string(forKey: "myUserRecordID") else {
//            logger.error("❌ CRITICAL: Не удалось получить ID ребенка из UserDefaults. Проверка невозможна.")
//            return
//        }
//        
//        do {
//            // 2. Загружаем все необработанные команды с сервера.
//            let commands = try await CloudKitManager.shared.fetchPendingCommands(for: childID)
//            
//            if commands.isEmpty {
//                logger.info("📪 Новых команд нет. Применяю последнее известное состояние.")
//                applyLastKnownState()
//                return
//            }
//            
//            // 3. Исполняем каждую команду.
//            for command in commands {
//                if let commandName = command["commandName"] as? String {
//                    logger.info("🎬 Исполнение команды '\(commandName)'")
//                    applyCommand(name: commandName)
//                }
//                
//                // 4. Удаляем команду с сервера ПОСЛЕ ее исполнения.
//                try await CloudKitManager.shared.publicDatabase.deleteRecord(withID: command.recordID)
//                logger.info("✅ Команда \(command.recordID.recordName) удалена.")
//            }
//            
//        } catch {
//            logger.error("🚨 Ошибка при проверке/исполнении команд: \(error)")
//        }
//    }
//    
//    /// Применяет конкретное правило блокировки.
//    private func applyCommand(name: String) {
//        switch name {
//        case "block_all_apps":
//            store.shield.applicationCategories = .all()
//            sharedUserDefaults?.set(true, forKey: "isBlocked") // Сохраняем последнее состояние
//            
//        case "unblock_all_apps":
//            store.shield.applicationCategories = nil
//            sharedUserDefaults?.set(false, forKey: "isBlocked") // Сохраняем последнее состояние
//            
//        default:
//            break
//        }
//    }
//    
//    /// Применяет последнее сохраненное состояние (важно после перезагрузки).
//    private func applyLastKnownState() {
//        let isBlocked = sharedUserDefaults?.bool(forKey: "isBlocked") ?? false
//        logger.info("🔄 Применение последнего известного состояния: isBlocked = \(isBlocked)")
//        if isBlocked {
//            store.shield.applicationCategories = .all()
//        } else {
//            store.shield.applicationCategories = nil
//        }
//    }
//}
