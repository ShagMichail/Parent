//
//  CloudKitManager.swift
//  Parent
//
//  Created by Михаил Шаговитов on 17.11.2025.
//

import Foundation
import CloudKit
import Combine
import UIKit
import CoreLocation

//protocol CloudKitCommandExecutor: AnyObject {
//    func executeCommand(name: String, recordID: CKRecord.ID)
//}
//
//class CloudKitManager: ObservableObject {
//    static let shared = CloudKitManager()
//    
//    weak var commandExecutor: CloudKitCommandExecutor?
//    
//    @Published var pendingCommands: [String: CommandStatus] = [:] // recordID: status
//    
//    private let container = CKContainer.default()
//    var publicDatabase: CKDatabase { container.publicCloudDatabase }
//    var privateDatabase: CKDatabase { container.privateCloudDatabase }
//    
//    
//    func fetchUserRecordID() async -> String? {
//        do {
//            let recordID = try await container.userRecordID()
//            return recordID.recordName
//        } catch {
//            print("🚨 Не удалось получить User Record ID: \(error)")
//            return nil
//        }
//    }
//    
//    func createInvitation() async throws -> String {
//        guard let childID = await fetchUserRecordID() else {
//            throw NSError(domain: "CloudKitManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Не удалось получить ID пользователя"])
//        }
//        
//        let invitationCode = String(format: "%06d", Int.random(in: 0...999999))
//        
//        let recordID = CKRecord.ID(recordName: UUID().uuidString)
//        let record = CKRecord(recordType: "Invitation", recordID: recordID)
//        
//        record["invitationCode"] = invitationCode as CKRecordValue
//        
//        record["childUserRecordID"] = childID as CKRecordValue
//        record["createdAt"] = Date() as CKRecordValue
//        
//        do {
//            try await container.publicCloudDatabase.save(record)
//            print("✅ Приглашение с кодом \(invitationCode) создано в public database.")
//            return invitationCode
//        } catch {
//            print("❌ Ошибка создания приглашения: \(error)")
//            throw error
//        }
//    }
//    
//    func acceptInvitation(withCode code: String) async throws -> (childID: String, recordToUpdate: CKRecord) {
//        print("=== 🔍 ПОИСК ПРИГЛАШЕНИЯ ПО ПОЛЮ 'invitationCode' ===")
//        
//        let predicate = NSPredicate(format: "invitationCode == %@", code)
//        let query = CKQuery(recordType: "Invitation", predicate: predicate)
//        
//        let record: CKRecord
//        
//        do {
//            let (matchResults, _) = try await container.publicCloudDatabase.records(matching: query)
//            
//            if let firstMatch = matchResults.first {
//                record = try firstMatch.1.get()
//                print("✅ Найдена запись для кода \(code)")
//            } else {
//                throw NSError(domain: "CloudKitManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "Код не найден или недействителен"])
//            }
//        } catch {
//            print("❌ Ошибка при поиске приглашения: \(error.localizedDescription)")
//            throw error
//        }
//        
//        guard let childID = record["childUserRecordID"] as? String else {
//            throw NSError(domain: "CloudKitManager", code: 500, userInfo: [NSLocalizedDescriptionKey: "Запись повреждена (отсутствует ID ребенка)"])
//        }
//        
//        print("✅ Приглашение найдено! ID ребенка: \(childID)")
//        return (childID, record)
//    }
//    
//    func subscribeToInvitationUpdates(invitationCode: String) async throws {
//        let subscriptionID = "invitation-\(invitationCode)-accepted"
//        
//        let subscriptions = try await container.publicCloudDatabase.allSubscriptions()
//        if subscriptions.contains(where: { $0.subscriptionID == subscriptionID }) {
//            try await container.publicCloudDatabase.deleteSubscription(withID: subscriptionID)
//            print("ℹ️ Старая подписка \(subscriptionID) удалена.")
//        }
//        
//        let predicate = NSPredicate(format: "invitationCode == %@", invitationCode)
//        
//        let subscription = CKQuerySubscription(
//            recordType: "Invitation",
//            predicate: predicate,
//            subscriptionID: subscriptionID,
//            options: .firesOnRecordUpdate
//        )
//        
//        let notificationInfo = CKSubscription.NotificationInfo()
//        notificationInfo.shouldSendContentAvailable = true
//        subscription.notificationInfo = notificationInfo
//        
//        try await container.publicCloudDatabase.save(subscription)
//        print("✅ Ребенок успешно подписался на обновления для приглашения с кодом \(invitationCode)")
//    }
//    
//    func handleRemoteNotificationForInvitation(userInfo: [AnyHashable: Any]) {
//        if let notification = CKQueryNotification(fromRemoteNotificationDictionary: userInfo) {
//            if notification.queryNotificationReason == .recordUpdated {
//                print("📬 Получен push об обновлении приглашения!")
//                NotificationCenter.default.post(name: NSNotification.Name("InvitationAccepted"), object: nil)
//            }
//        }
//    }
//    
//    func deleteInvitation(withCode code: String) async throws {
//        let recordID = CKRecord.ID(recordName: code)
//        try await container.publicCloudDatabase.deleteRecord(withID: recordID)
//        print("✅ Ребенок сам удалил свое приглашение \(code).   НЕ УДАЛИЛ, НАДО СМОТРЕТЬ!")
//    }
//    
//    func getCommandStatus(for recordID: String) async -> CommandStatus.Status? {
//        if let status = await MainActor.run(body: {
//            pendingCommands[recordID]?.status
//        }) {
//            return status
//        }
//        return nil
//    }
//    
//    func subscribeToCommands(for childID: String) async throws {
//        let subscriptionID = "commands-for-user-\(childID)"
//        
//        let subscriptions = try await publicDatabase.allSubscriptions()
//        if subscriptions.contains(where: { $0.subscriptionID == subscriptionID }) {
//            try await publicDatabase.deleteSubscription(withID: subscriptionID)
//            print("ℹ️ Старая подписка на команды удалена.")
//        }
//        
//        let predicate = NSPredicate(format: "targetChildID == %@", childID)
//        
//        let subscription = CKQuerySubscription(
//            recordType: "Command",
//            predicate: predicate,
//            subscriptionID: subscriptionID,
//            options: .firesOnRecordCreation
//        )
//        
//        let notificationInfo = CKSubscription.NotificationInfo()
//        notificationInfo.shouldSendContentAvailable = true
//        subscription.notificationInfo = notificationInfo
//        
//        try await publicDatabase.save(subscription)
//        print("✅ Ребенок \(childID) успешно подписался на получение команд.")
//    }
//    
//    func handleRemoteNotificationForCommand(userInfo: [AnyHashable: Any]) {
//        if let notification = CKQueryNotification(fromRemoteNotificationDictionary: userInfo) {
//            
//            guard notification.queryNotificationReason == .recordCreated,
//                  let recordID = notification.recordID else {
//                return
//            }
//            
//            print("📬 Получен push о новой команде! RecordID: \(recordID.recordName)")
//            
//            Task {
//                do {
//                    let record = try await publicDatabase.record(for: recordID)
//                    if let commandName = record["commandName"] as? String {
//                        print("📬 Команда: \(commandName)")
//                        await MainActor.run {
//                            commandExecutor?.executeCommand(name: commandName, recordID: recordID)
//                        }
//                    }
//                } catch {
//                    print("🚨 Не удалось загрузить запись команды из CloudKit: \(error)")
//                }
//            }
//        }
//    }
//    
//    private func updateCommandStatus(recordID: CKRecord.ID, status: CommandStatus.Status) async {
//        do {
//            let record = try await publicDatabase.record(for: recordID)
//            record["status"] = status.rawValue as CKRecordValue
//            record["executedAt"] = Date() as CKRecordValue
//            
//            try await publicDatabase.save(record)
//            print("✅ Статус команды обновлен: \(status.rawValue)")
//        } catch {
//            print("❌ Ошибка обновления статуса команды: \(error)")
//        }
//    }
//    
//    func runConnectivityTest() async {
//        print("--- 🏁 ЗАПУСК ПРОВЕРКИ ПОДКЛЮЧЕНИЯ CLOUDKIT ---")
//        
//        print("--- [Этап 1/2] Проверка статуса учетной записи iCloud...")
//        var accountIsAvailable = false
//        do {
//            let status = try await container.accountStatus()
//            switch status {
//            case .available:
//                print("--- ✅ [Этап 1] УСПЕХ: Учетная запись iCloud доступна. Подключение к контейнеру возможно.")
//                accountIsAvailable = true
//            case .noAccount:
//                print("--- ❌ [Этап 1] ПРОВАЛ: Пользователь не вошел в учетную запись iCloud на этом устройстве/симуляторе.")
//            case .restricted:
//                print("--- ❌ [Этап 1] ПРОВАЛ: Доступ к iCloud ограничен (например, родительским контролем на самом устройстве).")
//            case .couldNotDetermine:
//                print("--- ❌ [Этап 1] ПРОВАЛ: Не удалось определить статус. Возможны проблемы с сетью или серверами Apple.")
//            @unknown default:
//                print("--- ❌ [Этап 1] ПРОВАЛ: Неизвестный статус учетной записи.")
//            }
//        } catch {
//            print("--- 🚨 [Этап 1] КРИТИЧЕСКАЯ ОШИБКА при проверке статуса: \(error)")
//        }
//        
//        guard accountIsAvailable else {
//            print("--- 🛑 ПРОВЕРКА ОСТАНОВЛЕНА: Учетная запись iCloud недоступна. ---")
//            return
//        }
//        
//        print("\n--- [Этап 2/2] Попытка сохранить тестовую запись в контейнер...")
//        let testRecord = CKRecord(recordType: "ConnectivityTest")
//        testRecord["testMessage"] = "Hello, CloudKit!" as CKRecordValue
//        
//        do {
//            try await publicDatabase.save(testRecord)
//            print("--- ✅✅✅ [Этап 2] СУПЕР-УСПЕХ! Тестовая запись успешно сохранена.")
//            print("--- Это означает, что ваше приложение имеет полные права на чтение/запись в контейнер.")
//            
//            try await publicDatabase.deleteRecord(withID: testRecord.recordID)
//            print("--- (Тестовая запись успешно удалена)")
//            
//        } catch {
//            print("--- ❌❌❌ [Этап 2] ПРОВАЛ! Получена ошибка при сохранении тестовой записи. Вот она:")
//            print("--- \(error)")
//            print("--- Если это ошибка 'Permission Failure', то проблема 100% в несоответствии Bundle ID и контейнера.")
//        }
//        print("--- ✅ ПРОВЕРКА ПОДКЛЮЧЕНИЯ ЗАВЕРШЕНА ---")
//    }
//    
//    private func savePendingCommand(commandName: String, recordID: CKRecord.ID) {
//        let pendingCommand: [String: Any] = [
//            "commandName": commandName,
//            "recordID": recordID.recordName,
//            "timestamp": Date(),
//            "attempts": 1
//        ]
//        
//        UserDefaults.standard.set(pendingCommand, forKey: "pendingCommand")
//        print("💾 Команда сохранена для гарантированного выполнения: \(commandName)")
//    }
//    
//    private func saveFailedCommand(recordID: CKRecord.ID, error: String) {
//        let failedCommand: [String: Any] = [
//            "recordID": recordID.recordName,
//            "error": error,
//            "timestamp": Date()
//        ]
//        
//        UserDefaults.standard.set(failedCommand, forKey: "failedCommand")
//    }
//    
//    private func executeCommandInBackground(name: String, recordID: CKRecord.ID) async {
//        print("🔧 Выполняем команду в фоне: \(name)")
//        
//        await MainActor.run {
//            commandExecutor?.executeCommand(name: name, recordID: recordID)
//        }
//        
//        do {
//            try await publicDatabase.deleteRecord(withID: recordID)
//            print("✅ Команда выполнена и удалена из CloudKit: \(name)")
//            
//            UserDefaults.standard.removeObject(forKey: "pendingCommand")
//            UserDefaults.standard.removeObject(forKey: "failedCommand")
//            
//        } catch {
//            print("❌ Не удалось удалить команду из CloudKit: \(error)")
//        }
//    }
//    
//    private func retryFailedCommand(recordID: CKRecord.ID) async {
//        do {
//            let record = try await publicDatabase.record(for: recordID)
//            if let commandName = record["commandName"] as? String {
//                print("🔄 Повторяем выполнение команды: \(commandName)")
//                await self.executeCommandInBackground(name: commandName, recordID: recordID)
//            }
//        } catch {
//            print("❌ Не удалось повторить команду: \(error)")
//        }
//    }
//    
//    func sendCommand(name: String, to childID: String) async throws -> String {
//        let record = CKRecord(recordType: "Command")
//        let recordID = record.recordID.recordName
//        
//        record["commandName"] = name as CKRecordValue
//        record["targetChildID"] = childID as CKRecordValue
//        record["createdAt"] = Date() as CKRecordValue
//        record["status"] = "pending" as CKRecordValue
//        record["senderDeviceID"] = getDeviceIdentifier() as CKRecordValue // ID устройства родителя
//        
//        try await container.publicCloudDatabase.save(record)
//        print("✅ Команда '\(name)' отправлена ребенку \(childID)")
//        
//        let commandStatus = CommandStatus(
//            recordID: recordID,
//            commandName: name,
//            targetChildID: childID,
//            sentAt: Date(),
//            status: .pending,
//            updatedAt: Date(),
//            lastChecked: Date(),
//            attempts: 0
//        )
//        
//        await MainActor.run {
//            pendingCommands[recordID] = commandStatus
//        }
//        
//        startSmartStatusTracking(for: recordID)
//        
//        return recordID
//    }
//    
//    func startSmartStatusTracking(for recordID: String) {
//        Task {
//            var isComplited = false
//            var attempts = 0
//            while !isComplited {
//                try? await Task.sleep(nanoseconds: 2_000_000_000)
//                attempts += 1
//                
//                do {
//                    let record = try await container.publicCloudDatabase.record(for: CKRecord.ID(recordName: recordID))
//                    
//                    if let statusString = record["status"] as? String,
//                       let status = CommandStatus.Status(rawValue: statusString) {
//                        
//                        await updateCommandStatus(recordID: recordID, status: status, attempt: attempts)
//                        
//                        if status == .executed {
//                            print("✅ Команда выполнена, отслеживание завершено")
//                            isComplited = true
//                            scheduleRemoval(of: recordID, delay: 5)
//                            break
//                        }
//                    }
//                    
//                } catch let error as CKError {
//                    if error.code == .unknownItem {
//                        print("📭 Запись команды \(recordID) удалена ребенком - считаем выполненной")
//                        isComplited = true
//                        await updateCommandStatus(recordID: recordID, status: .notFound, attempt: attempts)
//                        scheduleRemoval(of: recordID, delay: 3)
//                        break
//                    } else {
//                        print("❌ Ошибка CloudKit: \(error)")
//                        isComplited = true
//                        await updateCommandStatus(recordID: recordID, status: .failed, attempt: attempts)
//                    }
//                } catch {
//                    print("❌ Ошибка проверки статуса: \(error)")
//                    isComplited = true
//                    await updateCommandStatus(recordID: recordID, status: .failed, attempt: attempts)
//                }
//            }
//        }
//    }
//    
//    @MainActor
//    public func updateCommandStatus(recordID: String, status: CommandStatus.Status, attempt: Int) {
//        if var commandStatus = pendingCommands[recordID] {
//            commandStatus.status = status
//            commandStatus.updatedAt = Date()
//            commandStatus.lastChecked = Date()
//            commandStatus.attempts = attempt
//            pendingCommands[recordID] = commandStatus
//            
//            print("🔄 Статус команды \(recordID) обновлен: \(status.rawValue) (попытка \(attempt))")
//        }
//    }
//    
//    private func scheduleRemoval(of recordID: String, delay: Int) {
//        Task {
//            try? await Task.sleep(nanoseconds: UInt64(delay) * 1_000_000_000)
//            await MainActor.run {
//                pendingCommands.removeValue(forKey: recordID)
//                print("🧹 Команда \(recordID) удалена из отслеживания")
//            }
//        }
//    }
//    
//    private func getDeviceIdentifier() -> String {
//        return UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
//    }
//}
//
//extension CloudKitManager {
//    func fetchNewCommands() async {
//        guard await AuthenticationManager.shared.userRole == .child else { return }
//        
//        print("🔍 АКТИВНАЯ проверка новых команд в \(Date())")
//        
//        guard let childID = await AuthenticationManager.shared.myUserRecordID else {
//            print("❌ Не удалось получить ID ребенка")
//            return
//        }
//        
//        let lastCheckKey = "lastCommandCheckTimestamp_\(childID)"
//        let lastCheck = UserDefaults.standard.double(forKey: lastCheckKey)
//        let threeMinutesAgo = Date().addingTimeInterval(-3 * 60).timeIntervalSince1970
//        
//        if lastCheck > threeMinutesAgo {
//            print("⏭️ Пропускаем проверку - последняя была менее 2 минут назад")
//            return
//        }
//        
//        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: lastCheckKey)
//        
//        let predicate = NSPredicate(format: "targetChildID == %@", childID)
//        let query = CKQuery(recordType: "Command", predicate: predicate)
//        query.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
//        
//        do {
//            let results = try await publicDatabase.records(matching: query)
//            print("✅ Найдено \(results.matchResults.count) команд для ребенка \(childID)")
//            
//            var foundNewCommands = false
//            
//            for (recordID, result) in results.matchResults {
//                switch result {
//                case .success(let record):
//                    if let commandName = record["commandName"] as? String {
//                        print("🆕 Найдена команда: \(commandName)")
//                        
//                        if !self.isCommandAlreadyExecuted(recordID: recordID) {
//                            foundNewCommands = true
//                            self.savePendingCommand(commandName: commandName, recordID: recordID)
//                            await self.executeCommandInBackground(name: commandName, recordID: recordID)
//                        }
//                    }
//                    
//                case .failure(let error):
//                    print("❌ Ошибка загрузки команды: \(error)")
//                }
//            }
//            
//            if !foundNewCommands {
//                print("📭 Новых команд не найдено")
//            }
//            
//        } catch {
//            print("❌ Ошибка проверки новых команд: \(error)")
//        }
//    }
//    
//    private func isCommandAlreadyExecuted(recordID: CKRecord.ID) -> Bool {
//        let executedCommandsKey = "executedCommands"
//        var executedCommands = UserDefaults.standard.stringArray(forKey: executedCommandsKey) ?? []
//        
//        if executedCommands.contains(recordID.recordName) {
//            print("⏭️ Команда \(recordID.recordName) уже выполнялась - пропускаем")
//            return true
//        }
//        
//        executedCommands.append(recordID.recordName)
//        if executedCommands.count > 100 {
//            executedCommands.removeFirst(50)
//        }
//        UserDefaults.standard.set(executedCommands, forKey: executedCommandsKey)
//        
//        return false
//    }
//    
//    func processPendingCommands() async {
//        guard await AuthenticationManager.shared.userRole == .child else { return }
//        
//        print("🔄 Обрабатываем ожидающие команды в \(Date())")
//        
//        // Проверяем pending команду
//        if let pendingCommand = UserDefaults.standard.dictionary(forKey: "pendingCommand"),
//           let commandName = pendingCommand["commandName"] as? String,
//           let recordIDString = pendingCommand["recordID"] as? String {
//            
//            let recordID = CKRecord.ID(recordName: recordIDString)
//            let attempts = pendingCommand["attempts"] as? Int ?? 1
//            
//            print("🎯 Выполняем ожидающую команду: \(commandName) (попытка \(attempts))")
//            
//            if attempts >= 5 {
//                UserDefaults.standard.removeObject(forKey: "pendingCommand")
//                print("🧹 Очищаем команду после 5 неудачных попыток")
//                return
//            }
//            
//            await self.executeCommandInBackground(name: commandName, recordID: recordID)
//            
//        } else {
//            print("📭 Ожидающих команд нет")
//        }
//    }
//}
//
//extension CloudKitManager {
//    func quickCommandCheck() async {
//        guard await AuthenticationManager.shared.userRole == .child,
//              let childID = await AuthenticationManager.shared.myUserRecordID else {
//            return
//        }
//        
//        let timeout: UInt64 = 10_000_000_000
//        
//        do {
//            try await withThrowingTaskGroup(of: Void.self) { group in
//                group.addTask {
//                    try await Task.sleep(nanoseconds: timeout)
//                    throw NSError(domain: "Timeout", code: -1, userInfo: nil)
//                }
//                
//                group.addTask {
//                    let fiveMinutesAgo = Date().addingTimeInterval(-5 * 60)
//                    let predicate = NSPredicate(format: "targetChildID == %@ AND createdAt >= %@", childID, fiveMinutesAgo as CVarArg)
//                    let query = CKQuery(recordType: "Command", predicate: predicate)
//                    
//                    let results = try await self.publicDatabase.records(matching: query, desiredKeys: ["commandName"])
//                    
//                    for (recordID, result) in results.matchResults {
//                        if case .success(let record) = result,
//                           let commandName = record["commandName"] as? String {
//                            await self.executeCommandInBackground(name: commandName, recordID: recordID)
//                        }
//                    }
//                }
//                
//                try await group.next()
//                group.cancelAll()
//            }
//        } catch {
//            
//        }
//    }
//}
//
//extension CloudKitManager {
//    
//    // MARK: - Отправка геопозиции ребенка
//    
//    func sendLocationUpdate(
//        latitude: Double,
//        longitude: Double,
//        timestamp: Date,
//        childID: String
//    ) async throws -> CKRecord {
//        let record = CKRecord(recordType: "ChildLocation")
//        
//        print("📤 Отправка геолокации:")
//        print("   childID: '\(childID)'")
//        print("   latitude: \(latitude)")
//        print("   longitude: \(longitude)")
//        print("   timestamp: \(timestamp)")
//        // Основные данные
//        record["childID"] = childID as CKRecordValue
//        record["latitude"] = latitude as CKRecordValue
//        record["longitude"] = longitude as CKRecordValue
//        record["timestamp"] = timestamp as CKRecordValue
//        
//        // Геолокация для CloudKit
//        let location = CLLocation(latitude: latitude, longitude: longitude)
//        record["location"] = location
//        
//        // Метаданные
//        record["deviceName"] = await UIDevice.current.name as CKRecordValue
//        record["batteryLevel"] = await UIDevice.current.batteryLevel as CKRecordValue
//        record["isCharging"] = await (UIDevice.current.batteryState == .charging) as CKRecordValue
//        
//        // Сохраняем в приватную зону (доступно только родителю и ребенку)
//        return try await privateDatabase.save(record)
//    }
//    
//    // MARK: - Получение истории геопозиций
//    
//    func fetchLocationHistory(for childID: String, hours: Int = 24) async throws -> [ChildLocation] {
//        print("= * 50")
//        print("🔍 ЗАПРОС ИСТОРИИ ГЕОЛОКАЦИИ")
//        print("   childID: '\(childID)'")
//        print("   Тип childID: \(type(of: childID))")
//        print("   Длина: \(childID.count) символов")
//        print("= * 50")
//        
//        let allPredicate = NSPredicate(value: true)
//        let allQuery = CKQuery(recordType: "ChildLocation", predicate: allPredicate)
//        
//        do {
//            let (allResults, _) = try await privateDatabase.records(matching: allQuery)
//            print("📊 ВСЕ записи в базе: \(allResults.count)")
//            
//            if allResults.isEmpty {
//                print("⚠️ База данных ПУСТА! Нет записей ChildLocation")
//                return []
//            }
//            
//            var foundChildIDs: Set<String> = []
//            for (recordID, result) in allResults {
//                if case .success(let record) = result {
//                    if let storedChildID = record["childID"] as? String {
//                        foundChildIDs.insert(storedChildID)
//                        print("   Найден childID: '\(storedChildID)' в записи \(recordID.recordName)")
//                    } else {
//                        print("   ❌ В записи \(recordID.recordName) нет childID или он не строка")
//                    }
//                }
//            }
//            
//            print("📋 Уникальные childID в базе: \(foundChildIDs)")
//            
//            if foundChildIDs.contains(childID) {
//                print("✅ Наш childID '\(childID)' найден в базе!")
//            } else {
//                print("❌ Наш childID '\(childID)' НЕ найден в базе!")
//                print("   Доступные childID: \(Array(foundChildIDs))")
//                return []
//            }
//            
//            let startDate = Date().addingTimeInterval(-Double(hours) * 3600)
//            let predicate = NSPredicate(format: "childID == %@ AND timestamp >= %@",
//                                      childID, startDate as CVarArg)
//            
//            let query = CKQuery(recordType: "ChildLocation", predicate: predicate)
//            query.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
//            
//            print("📡 Выполняем запрос с фильтром...")
//            let (matchResults, _) = try await privateDatabase.records(matching: query)
//            
//            print("📊 Найдено записей по фильтру: \(matchResults.count)")
//            
//            var locations: [ChildLocation] = []
//            
//            for (recordID, result) in matchResults {
//                switch result {
//                case .success(let record):
//                    print("   📍 Обрабатываем запись \(recordID.recordName)")
//                    
//                    // Отладочная информация
//                    print("      - childID: \(record["childID"] ?? "нет")")
//                    print("      - timestamp: \(record["timestamp"] ?? "нет")")
//                    print("      - latitude: \(record["latitude"] ?? "нет")")
//                    print("      - longitude: \(record["longitude"] ?? "нет")")
//                    
//                    if let location = ChildLocation(from: record) {
//                        locations.append(location)
//                        print("      ✅ Успешно создана локация")
//                    } else {
//                        print("      ❌ Не удалось создать ChildLocation")
//                    }
//                    
//                case .failure(let error):
//                    print("   ❌ Ошибка записи \(recordID): \(error)")
//                }
//            }
//            
//            print("📍 ИТОГО: \(locations.count) локаций")
//            print("= * 50")
//            
//            return locations
//            
//        } catch {
//            print("❌ КРИТИЧЕСКАЯ ОШИБКА: \(error)")
//            print("= * 50")
//            throw error
//        }
//    }
//    
//    // MARK: - Подписка на обновления геопозиций
//    
//    func subscribeToLocationUpdates(for childID: String) async throws {
//        let predicate = NSPredicate(format: "childID == %@", childID)
//        let subscription = CKQuerySubscription(
//            recordType: "ChildLocation",
//            predicate: predicate,
//            subscriptionID: "location-updates-\(childID)",
//            options: [.firesOnRecordCreation]
//        )
//        
//        let notificationInfo = CKSubscription.NotificationInfo()
//        notificationInfo.titleLocalizationKey = "Новое местоположение"
//        notificationInfo.alertLocalizationKey = "%1$@ обновил местоположение"
//        notificationInfo.shouldSendContentAvailable = true
//        notificationInfo.desiredKeys = ["latitude", "longitude", "timestamp"]
//        
//        subscription.notificationInfo = notificationInfo
//        
//        try await privateDatabase.save(subscription)
//        print("✅ Подписка на обновления геолокации создана")
//    }
//}
//
//
//extension CloudKitManager {
//    // В CloudKitManager.swift
//
//    // --- НОВЫЙ ФЛОУ: РОДИТЕЛЬ СОЗДАЕТ, РЕБЕНОК ПРИНИМАЕТ ---
//
//    /// ВЫЗЫВАЕТСЯ РОДИТЕЛЕМ для создания кода-приглашения.
//    func createInvitationByParent() async throws -> String {
//        guard let parentID = await fetchUserRecordID() else {
//            throw NSError(domain: "CloudKitManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Не удалось получить ID родителя"])
//        }
//        
//        let invitationCode = String(format: "%06d", Int.random(in: 0...999999))
//        let record = CKRecord(recordType: "Invitation")
//        
//        record["invitationCode"] = invitationCode as CKRecordValue
//        record["parentUserRecordID"] = parentID as CKRecordValue
//        record["createdAt"] = Date() as CKRecordValue
//        
//        try await publicDatabase.save(record)
//        print("✅ Родитель создал приглашение с кодом \(invitationCode).")
//        return invitationCode
//    }
//
//    /// ВЫЗЫВАЕТСЯ РЕБЕНКОМ для принятия приглашения.
//    func acceptInvitationByChild(withCode code: String, childName: String) async throws -> String {
//        print("=== 👶 РЕБЕНОК: Поиск приглашения по коду \(code) ===")
//        
//        // 1. Находим запись по коду
//        let predicate = NSPredicate(format: "invitationCode == %@", code)
//        let query = CKQuery(recordType: "Invitation", predicate: predicate)
//        
//        let record: CKRecord
//        do {
//            let (matchResults, _) = try await publicDatabase.records(matching: query, resultsLimit: 1)
//            guard let firstMatch = matchResults.first else {
//                throw NSError(domain: "CloudKitManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "Код не найден или недействителен"])
//            }
//            record = try firstMatch.1.get()
//        } catch {
//            print("❌ Ошибка при поиске приглашения ребенком: \(error.localizedDescription)")
//            throw error
//        }
//
//        // 2. Извлекаем ID родителя из найденной записи
//        guard let parentID = record["parentUserRecordID"] as? String else {
//            throw NSError(domain: "CloudKitManager", code: 500, userInfo: [NSLocalizedDescriptionKey: "Запись повреждена (отсутствует ID родителя)"])
//        }
//        
//        // 3. Получаем ID самого ребенка
//        guard let childID = await fetchUserRecordID() else {
//            throw NSError(domain: "CloudKitManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Не удалось получить ID пользователя (ребенка)"])
//        }
//        
//        // 4. Добавляем ID ребенка в запись ("флажок" о принятии)
//        record["childUserRecordID"] = childID
//        record["childName"] = childName
//        // Также можно добавить имя, которое ввел ребенок
//        // record["childName"] = "Имя, которое ввел ребенок"
//        
//        // 5. Сохраняем измененную запись. Это вызовет push у родителя.
//        do {
//            try await publicDatabase.save(record)
//            print("✅ Ребенок \(childName) (\(childID)) принял приглашение от родителя \(parentID)")
//        } catch {
//            print("❌ Не удалось обновить запись приглашения: \(error)")
//            throw error
//        }
//        
//        return parentID
//    }
//
//
//    /// ВЫЗЫВАЕТСЯ РОДИТЕЛЕМ для подписки на принятие приглашения.
//    func subscribeToInvitationAcceptance(invitationCode: String) async throws {
//        let subscriptionID = "invitation-\(invitationCode)-accepted-by-child"
//        
//        // ... ваш код для удаления старой подписки ...
//        
//        let predicate = NSPredicate(format: "invitationCode == %@", invitationCode)
//        let subscription = CKQuerySubscription(
//            recordType: "Invitation",
//            predicate: predicate,
//            subscriptionID: subscriptionID,
//            options: .firesOnRecordUpdate // Срабатывать при ОБНОВЛЕНИИ
//        )
//        
//        let notificationInfo = CKSubscription.NotificationInfo()
//        notificationInfo.shouldSendContentAvailable = true
//        subscription.notificationInfo = notificationInfo
//        
//        try await publicDatabase.save(subscription)
//        print("✅ Родитель подписался на принятие приглашения с кодом \(invitationCode)")
//    }
//
//    /// ВЫЗЫВАЕТСЯ В APPDELEGATE РОДИТЕЛЯ, когда ребенок принимает приглашение.
//    func handleRemoteNotificationForInvitationAcceptance(userInfo: [AnyHashable: Any]) {
//        if let notification = CKQueryNotification(fromRemoteNotificationDictionary: userInfo),
//           notification.queryNotificationReason == .recordUpdated {
//            
//            print("📬 Родитель получил push об обновлении приглашения!")
//            
//            guard let recordID = notification.recordID else { return }
//            
//            // Загружаем обновленную запись, чтобы получить ID и имя ребенка
//            Task {
//                do {
//                    let record = try await publicDatabase.record(for: recordID)
//                    if let childID = record["childUserRecordID"] as? String,
//                       let childName = record["childName"] as? String {
//                        
//                        // Отправляем локальное уведомление с данными ребенка
//                        let childInfo = ["childID": childID, "childName": childName]
//                        NotificationCenter.default.post(
//                            name: NSNotification.Name("InvitationAcceptedByChild"),
//                            object: nil,
//                            userInfo: childInfo
//                        )
//                    }
//                    
//                    // Удаляем запись, так как она больше не нужна
//                    try? await publicDatabase.deleteRecord(withID: recordID)
//                    
//                } catch {
//                    print("🚨 Не удалось загрузить/удалить запись после принятия: \(error)")
//                }
//            }
//        }
//    }
//
//   
//}

// CloudKitManager.swift

import Foundation
import CloudKit
import UIKit // Для UIDevice

// Протокол, который будет реализовывать AuthenticationManager на устройстве ребенка
protocol CloudKitCommandExecutor: AnyObject {
    func executeCommand(name: String, recordID: CKRecord.ID)
}

enum CommandStatus: String {
    case pending    // Отправлена, ждет выполнения
    case executed   // Успешно выполнена ребенком
    case failed     // Ошибка выполнения
}

class CloudKitManager: ObservableObject {
    static let shared = CloudKitManager()
    
    weak var commandExecutor: CloudKitCommandExecutor?
    
    let container = CKContainer.default()
    var publicDatabase: CKDatabase { container.publicCloudDatabase }
    
    // MARK: - User Management
    
    func fetchUserRecordID() async -> String? {
        do {
            let recordID = try await container.userRecordID()
            return recordID.recordName
        } catch {
            print("🚨 CloudKitManager: Не удалось получить User Record ID: \(error)")
            return nil
        }
    }
    
    // MARK: - Pairing Flow (Parent creates, Child accepts)
    
    /// ВЫЗЫВАЕТСЯ РОДИТЕЛЕМ для создания кода-приглашения.
    func createInvitationByParent() async throws -> String {
        guard let parentID = await fetchUserRecordID() else {
            throw NSError(domain: "CloudKitManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Не удалось получить ID родителя"])
        }
        
        let invitationCode = String(format: "%06d", Int.random(in: 0...999999))
        let record = CKRecord(recordType: "Invitation")
        
        record["invitationCode"] = invitationCode as CKRecordValue
        record["parentUserRecordID"] = parentID as CKRecordValue
        record["createdAt"] = Date() as CKRecordValue
        
        try await publicDatabase.save(record)
        print("✅ CloudKitManager: Родитель создал приглашение с кодом \(invitationCode).")
        return invitationCode
    }

    /// ВЫЗЫВАЕТСЯ РЕБЕНКОМ для принятия приглашения.
    func acceptInvitationByChild(withCode code: String, childName: String) async throws -> String {
        let predicate = NSPredicate(format: "invitationCode == %@", code)
        let query = CKQuery(recordType: "Invitation", predicate: predicate)
        
        let (matchResults, _) = try await publicDatabase.records(matching: query, resultsLimit: 1)
        
        guard let record = try matchResults.first?.1.get() else {
            throw NSError(domain: "CloudKitManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "Код не найден или недействителен"])
        }

        guard let parentID = record["parentUserRecordID"] as? String else {
            throw NSError(domain: "CloudKitManager", code: 500, userInfo: [NSLocalizedDescriptionKey: "Запись повреждена (нет ID родителя)"])
        }
        
        guard let childID = await fetchUserRecordID() else {
            throw NSError(domain: "CloudKitManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Не удалось получить ID ребенка"])
        }
        
        record["childUserRecordID"] = childID
        record["childName"] = childName
        
        try await publicDatabase.save(record) // Это действие триггерит push родителю
        print("✅ CloudKitManager: Ребенок \(childName) принял приглашение от родителя \(parentID)")
        return parentID
    }

    /// ВЫЗЫВАЕТСЯ РОДИТЕЛЕМ для подписки на принятие приглашения.
    func subscribeToInvitationAcceptance(invitationCode: String) async throws {
        let subscriptionID = "invitation-accepted-\(invitationCode)"
        let predicate = NSPredicate(format: "invitationCode == %@", invitationCode)
        
        let subscription = CKQuerySubscription(
            recordType: "Invitation",
            predicate: predicate,
            subscriptionID: subscriptionID,
            options: .firesOnRecordUpdate
        )
        
        let notificationInfo = CKSubscription.NotificationInfo()
        
        notificationInfo.shouldSendContentAvailable = true
        notificationInfo.desiredKeys = ["childUserRecordID", "childName"]
        
        subscription.notificationInfo = notificationInfo
        try await publicDatabase.save(subscription)
    }
    
    // MARK: - Command Flow
    
    /// ВЫЗЫВАЕТСЯ РОДИТЕЛЕМ для отправки команды.
    func sendCommand(name: String, to childID: String) async throws {
        let record = CKRecord(recordType: "Command")
        record["commandName"] = name as CKRecordValue
        record["targetChildID"] = childID as CKRecordValue
        record["status"] = CommandStatus.pending.rawValue as CKRecordValue // Ставим статус "ожидание"
        record["createdAt"] = Date() as CKRecordValue
        
        // Сохраняем
        try await publicDatabase.save(record)
        print("✅ Command '\(name)' sent to \(childID) with status .pending")
    }
    
    /// ВЫЗЫВАЕТСЯ РЕБЕНКОМ для подписки на команды.
    func subscribeToCommands(for childID: String) async throws {
        let subscriptionID = "commands-for-user-\(childID)"
        
        // 1. Проверяем, есть ли уже подписка, чтобы не дублировать
        let subscriptions = try await publicDatabase.allSubscriptions()
        if subscriptions.contains(where: { $0.subscriptionID == subscriptionID }) {
            try await publicDatabase.deleteSubscription(withID: subscriptionID)
            print("ℹ️ Старая подписка на команды удалена.")
        }
        
        // 2. Условие: targetChildID равен моему ID
        let predicate = NSPredicate(format: "targetChildID == %@", childID)
        
        // 3. Создаем подписку на СОЗДАНИЕ (firesOnRecordCreation)
        let subscription = CKQuerySubscription(
            recordType: "Command",
            predicate: predicate,
            subscriptionID: subscriptionID,
            options: .firesOnRecordCreation // Важно! Родитель СОЗДАЕТ запись
        )
        
        // 4. Настраиваем уведомление
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.shouldSendContentAvailable = true // "Тихий" пуш для пробуждения приложения
        
        // Можно добавить keys, если созданы поля в Dashboard, иначе лучше не указывать
        // notificationInfo.desiredKeys = ["commandName", "recordID"]
        
        subscription.notificationInfo = notificationInfo
        
        try await publicDatabase.save(subscription)
        print("✅ [Child] Успешно подписались на команды для ID: \(childID)")
    }
    
    /// 3. Очистка выполненных команд (вызывается родителем после успеха)
    func deleteCommand(recordID: CKRecord.ID) async {
        do {
            try await publicDatabase.deleteRecord(withID: recordID)
            print("🗑 Command record deleted")
        } catch {
            print("⚠️ Failed to delete command: \(error)")
        }
    }
    
    /// ВЫЗЫВАЕТСЯ РОДИТЕЛЕМ: Подписка на изменение статуса команд
    func subscribeToCommandUpdates(for childID: String) async throws {
        let subscriptionID = "command-updates-\(childID)"
        
        // 1. Удаляем старую подписку (на всякий случай, чтобы не дублировать)
        try? await publicDatabase.deleteSubscription(withID: subscriptionID)
        
        // 2. Слушаем команды только для конкретного ребенка
        let predicate = NSPredicate(format: "targetChildID == %@", childID)
        
        // 3. Важно: options = .firesOnRecordUpdate
        // Мы хотим знать, когда РЕБЕНОК изменит статус (pending -> executed)
        let subscription = CKQuerySubscription(
            recordType: "Command",
            predicate: predicate,
            subscriptionID: subscriptionID,
            options: [.firesOnRecordUpdate]
        )
        
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        
        // Сразу просим вернуть нам статус и ID записи, чтобы не делать лишний запрос
        notificationInfo.desiredKeys = ["status", "commandName", "targetChildID"]
        
        subscription.notificationInfo = notificationInfo
        
        try await publicDatabase.save(subscription)
        print("✅ [Parent] Подписались на обновления команд ребенка: \(childID)")
    }
    
    // MARK: - Command Flow (Child Side)
    
    /// 4. РЕБЕНОК выполняет команду и обновляет статус
    func updateCommandStatus(recordID: CKRecord.ID, status: CommandStatus) async throws {
        // Сначала получаем свежую запись (CloudKit требует этого для update)
        let record = try await publicDatabase.record(for: recordID)
        record["status"] = status.rawValue as CKRecordValue
        
        try await publicDatabase.save(record)
        print("✅ Child updated command status to: \(status.rawValue)")
    }
    
    // Вспомогательный метод для получения конкретной команды (если пришел пуш без данных)
    func fetchRecord(recordID: CKRecord.ID) async throws -> CKRecord {
        return try await publicDatabase.record(for: recordID)
    }
}

extension CloudKitManager {
    /// Получает самую последнюю команду для ребенка (чтобы понять текущий статус)
    func fetchLatestCommand(for childID: String) async throws -> CKRecord? {
        let predicate = NSPredicate(format: "targetChildID == %@", childID)
        
        // Сортируем по дате создания (сначала новые)
        let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: false)
        
        let query = CKQuery(recordType: "Command", predicate: predicate)
        query.sortDescriptors = [sortDescriptor]
        
        // Запрашиваем только 1 запись (самую свежую)
        let (matchResults, _) = try await publicDatabase.records(matching: query, resultsLimit: 1)
        
        // Возвращаем первую найденную запись или nil
        return try matchResults.first?.1.get()
    }
}

// Добавьте это расширение для удобства
//extension Notification.Name {
//    static let invitationAcceptedByChild = Notification.Name("invitationAcceptedByChild")
//}


//func fetchPendingCommands(for childID: String) async throws -> [CKRecord] {
//    let predicate = NSPredicate(format: "targetChildID == %@", childID)
//    let query = CKQuery(recordType: "Command", predicate: predicate)
//    query.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
//    
//    let (matchResults, _) = try await publicDatabase.records(matching: query)
//    let records = matchResults.compactMap { try? $0.1.get() }
//    print("CloudKitManager: 🔍 Найдено \(records.count) команд для ребенка.")
//    return records
//}
