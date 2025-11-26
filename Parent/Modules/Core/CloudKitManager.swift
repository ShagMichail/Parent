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

protocol CloudKitCommandExecutor: AnyObject {
    func executeCommand(name: String, recordID: CKRecord.ID)
}

class CloudKitManager: ObservableObject {
    static let shared = CloudKitManager()
    
    weak var commandExecutor: CloudKitCommandExecutor?
    
    @Published var pendingCommands: [String: CommandStatus] = [:] // recordID: status
    
    private let container = CKContainer.default()
    var publicDatabase: CKDatabase { container.publicCloudDatabase }
    
    
    func fetchUserRecordID() async -> String? {
        do {
            let recordID = try await container.userRecordID()
            return recordID.recordName
        } catch {
            print("🚨 Не удалось получить User Record ID: \(error)")
            return nil
        }
    }
    
    func createInvitation() async throws -> String {
        guard let childID = await fetchUserRecordID() else {
            throw NSError(domain: "CloudKitManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Не удалось получить ID пользователя"])
        }
        
        let invitationCode = String(format: "%06d", Int.random(in: 0...999999))
        
        let recordID = CKRecord.ID(recordName: UUID().uuidString)
        let record = CKRecord(recordType: "Invitation", recordID: recordID)
        
        record["invitationCode"] = invitationCode as CKRecordValue
        
        record["childUserRecordID"] = childID as CKRecordValue
        record["createdAt"] = Date() as CKRecordValue
        
        do {
            try await container.publicCloudDatabase.save(record)
            print("✅ Приглашение с кодом \(invitationCode) создано в public database.")
            return invitationCode
        } catch {
            print("❌ Ошибка создания приглашения: \(error)")
            throw error
        }
    }
    
    func acceptInvitation(withCode code: String) async throws -> (childID: String, recordToUpdate: CKRecord) {
        print("=== 🔍 ПОИСК ПРИГЛАШЕНИЯ ПО ПОЛЮ 'invitationCode' ===")
        
        let predicate = NSPredicate(format: "invitationCode == %@", code)
        let query = CKQuery(recordType: "Invitation", predicate: predicate)
        
        let record: CKRecord
        
        do {
            let (matchResults, _) = try await container.publicCloudDatabase.records(matching: query)
            
            if let firstMatch = matchResults.first {
                record = try firstMatch.1.get()
                print("✅ Найдена запись для кода \(code)")
            } else {
                throw NSError(domain: "CloudKitManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "Код не найден или недействителен"])
            }
        } catch {
            print("❌ Ошибка при поиске приглашения: \(error.localizedDescription)")
            throw error
        }
        
        guard let childID = record["childUserRecordID"] as? String else {
            throw NSError(domain: "CloudKitManager", code: 500, userInfo: [NSLocalizedDescriptionKey: "Запись повреждена (отсутствует ID ребенка)"])
        }
        
        print("✅ Приглашение найдено! ID ребенка: \(childID)")
        return (childID, record)
    }
    
    func subscribeToInvitationUpdates(invitationCode: String) async throws {
        let subscriptionID = "invitation-\(invitationCode)-accepted"
        
        let subscriptions = try await container.publicCloudDatabase.allSubscriptions()
        if subscriptions.contains(where: { $0.subscriptionID == subscriptionID }) {
            try await container.publicCloudDatabase.deleteSubscription(withID: subscriptionID)
            print("ℹ️ Старая подписка \(subscriptionID) удалена.")
        }
        
        let predicate = NSPredicate(format: "invitationCode == %@", invitationCode)
        
        let subscription = CKQuerySubscription(
            recordType: "Invitation",
            predicate: predicate,
            subscriptionID: subscriptionID,
            options: .firesOnRecordUpdate
        )
        
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        subscription.notificationInfo = notificationInfo
        
        try await container.publicCloudDatabase.save(subscription)
        print("✅ Ребенок успешно подписался на обновления для приглашения с кодом \(invitationCode)")
    }
    
    func handleRemoteNotificationForInvitation(userInfo: [AnyHashable: Any]) {
        if let notification = CKQueryNotification(fromRemoteNotificationDictionary: userInfo) {
            if notification.queryNotificationReason == .recordUpdated {
                print("📬 Получен push об обновлении приглашения!")
                NotificationCenter.default.post(name: NSNotification.Name("InvitationAccepted"), object: nil)
            }
        }
    }
    
    func deleteInvitation(withCode code: String) async throws {
        let recordID = CKRecord.ID(recordName: code)
        try await container.publicCloudDatabase.deleteRecord(withID: recordID)
        print("✅ Ребенок сам удалил свое приглашение \(code).   НЕ УДАЛИЛ, НАДО СМОТРЕТЬ!")
    }
    

    private func startStatusTracking(for recordID: String) {
        Task {
            var attempts = 0
            let maxAttempts = 30
            
            while attempts < maxAttempts {
                try? await Task.sleep(nanoseconds: 1_000_000_000) // 2 секунды
                
                do {
                    let record = try await container.publicCloudDatabase.record(for: CKRecord.ID(recordName: recordID))
                    
                    if let statusString = record["status"] as? String,
                       let status = CommandStatus.Status(rawValue: statusString) {
                        
                        await updateCommandStatus(recordID: recordID, status: status)
                        
                        if status == .executed || status == .failed {
                            print("✅ Отслеживание завершено для команды \(recordID): \(status)")
                            break
                        }
                    }
                    
                } catch {
                    print("❌ Ошибка проверки статуса команды: \(error)")
                }
                
                attempts += 1
                
                if attempts >= maxAttempts {
                    await updateCommandStatus(recordID: recordID, status: .failed)
                }
            }
        }
    }
    
    @MainActor
    private func updateCommandStatus(recordID: String, status: CommandStatus.Status) {
        if var commandStatus = pendingCommands[recordID] {
            commandStatus.status = status
            commandStatus.updatedAt = Date()
            pendingCommands[recordID] = commandStatus
            
            print("🔄 Статус команды \(recordID) обновлен: \(status.rawValue)")
            
            if status == .executed {
                Task {
                    try? await Task.sleep(nanoseconds: 5_000_000_000)
                    pendingCommands.removeValue(forKey: recordID)
                }
            }
        }
    }
    
    func getCommandStatus(for recordID: String) async -> CommandStatus.Status? {
        if let status = await MainActor.run(body: {
            pendingCommands[recordID]?.status
        }) {
            return status
        }
        return nil
    }
    
    func subscribeToCommands(for childID: String) async throws {
        let subscriptionID = "commands-for-user-\(childID)"
        
        let subscriptions = try await publicDatabase.allSubscriptions()
        if subscriptions.contains(where: { $0.subscriptionID == subscriptionID }) {
            try await publicDatabase.deleteSubscription(withID: subscriptionID)
            print("ℹ️ Старая подписка на команды удалена.")
        }
        
        let predicate = NSPredicate(format: "targetChildID == %@", childID)
        
        let subscription = CKQuerySubscription(
            recordType: "Command",
            predicate: predicate,
            subscriptionID: subscriptionID,
            options: .firesOnRecordCreation
        )
        
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        subscription.notificationInfo = notificationInfo
        
        try await publicDatabase.save(subscription)
        print("✅ Ребенок \(childID) успешно подписался на получение команд.")
    }
    
    func handleRemoteNotificationForCommand(userInfo: [AnyHashable: Any]) {
        if let notification = CKQueryNotification(fromRemoteNotificationDictionary: userInfo) {
            
            guard notification.queryNotificationReason == .recordCreated,
                  let recordID = notification.recordID else {
                return
            }
            
            print("📬 Получен push о новой команде! RecordID: \(recordID.recordName)")
            
            Task {
                do {
                    let record = try await publicDatabase.record(for: recordID)
                    if let commandName = record["commandName"] as? String {
                        print("📬 Команда: \(commandName)")
                        await MainActor.run {
                            commandExecutor?.executeCommand(name: commandName, recordID: recordID)
                        }
                    }
                } catch {
                    print("🚨 Не удалось загрузить запись команды из CloudKit: \(error)")
                }
            }
        }
    }
    
    private func updateCommandStatus(recordID: CKRecord.ID, status: CommandStatus.Status) async {
        do {
            let record = try await publicDatabase.record(for: recordID)
            record["status"] = status.rawValue as CKRecordValue
            record["executedAt"] = Date() as CKRecordValue
            
            try await publicDatabase.save(record)
            print("✅ Статус команды обновлен: \(status.rawValue)")
        } catch {
            print("❌ Ошибка обновления статуса команды: \(error)")
        }
    }

    func runConnectivityTest() async {
        print("--- 🏁 ЗАПУСК ПРОВЕРКИ ПОДКЛЮЧЕНИЯ CLOUDKIT ---")
        
        print("--- [Этап 1/2] Проверка статуса учетной записи iCloud...")
        var accountIsAvailable = false
        do {
            let status = try await container.accountStatus()
            switch status {
            case .available:
                print("--- ✅ [Этап 1] УСПЕХ: Учетная запись iCloud доступна. Подключение к контейнеру возможно.")
                accountIsAvailable = true
            case .noAccount:
                print("--- ❌ [Этап 1] ПРОВАЛ: Пользователь не вошел в учетную запись iCloud на этом устройстве/симуляторе.")
            case .restricted:
                print("--- ❌ [Этап 1] ПРОВАЛ: Доступ к iCloud ограничен (например, родительским контролем на самом устройстве).")
            case .couldNotDetermine:
                print("--- ❌ [Этап 1] ПРОВАЛ: Не удалось определить статус. Возможны проблемы с сетью или серверами Apple.")
            @unknown default:
                print("--- ❌ [Этап 1] ПРОВАЛ: Неизвестный статус учетной записи.")
            }
        } catch {
            print("--- 🚨 [Этап 1] КРИТИЧЕСКАЯ ОШИБКА при проверке статуса: \(error)")
        }
        
        guard accountIsAvailable else {
            print("--- 🛑 ПРОВЕРКА ОСТАНОВЛЕНА: Учетная запись iCloud недоступна. ---")
            return
        }
        
        print("\n--- [Этап 2/2] Попытка сохранить тестовую запись в контейнер...")
        let testRecord = CKRecord(recordType: "ConnectivityTest")
        testRecord["testMessage"] = "Hello, CloudKit!" as CKRecordValue
        
        do {
            try await publicDatabase.save(testRecord)
            print("--- ✅✅✅ [Этап 2] СУПЕР-УСПЕХ! Тестовая запись успешно сохранена.")
            print("--- Это означает, что ваше приложение имеет полные права на чтение/запись в контейнер.")
            
            try await publicDatabase.deleteRecord(withID: testRecord.recordID)
            print("--- (Тестовая запись успешно удалена)")
            
        } catch {
            print("--- ❌❌❌ [Этап 2] ПРОВАЛ! Получена ошибка при сохранении тестовой записи. Вот она:")
            print("--- \(error)")
            print("--- Если это ошибка 'Permission Failure', то проблема 100% в несоответствии Bundle ID и контейнера.")
        }
        print("--- ✅ ПРОВЕРКА ПОДКЛЮЧЕНИЯ ЗАВЕРШЕНА ---")
    }
    
    private func savePendingCommand(commandName: String, recordID: CKRecord.ID) {
        let pendingCommand: [String: Any] = [
            "commandName": commandName,
            "recordID": recordID.recordName,
            "timestamp": Date(),
            "attempts": 1
        ]
        
        UserDefaults.standard.set(pendingCommand, forKey: "pendingCommand")
        print("💾 Команда сохранена для гарантированного выполнения: \(commandName)")
    }
    
    private func saveFailedCommand(recordID: CKRecord.ID, error: String) {
        let failedCommand: [String: Any] = [
            "recordID": recordID.recordName,
            "error": error,
            "timestamp": Date()
        ]
        
        UserDefaults.standard.set(failedCommand, forKey: "failedCommand")
    }
    
    private func executeCommandInBackground(name: String, recordID: CKRecord.ID) async {
        print("🔧 Выполняем команду в фоне: \(name)")
        
        await MainActor.run {
            commandExecutor?.executeCommand(name: name, recordID: recordID)
        }
        
        do {
            try await publicDatabase.deleteRecord(withID: recordID)
            print("✅ Команда выполнена и удалена из CloudKit: \(name)")
            
            UserDefaults.standard.removeObject(forKey: "pendingCommand")
            UserDefaults.standard.removeObject(forKey: "failedCommand")
            
        } catch {
            print("❌ Не удалось удалить команду из CloudKit: \(error)")
        }
    }
    
    private func retryFailedCommand(recordID: CKRecord.ID) async {
        do {
            let record = try await publicDatabase.record(for: recordID)
            if let commandName = record["commandName"] as? String {
                print("🔄 Повторяем выполнение команды: \(commandName)")
                await self.executeCommandInBackground(name: commandName, recordID: recordID)
            }
        } catch {
            print("❌ Не удалось повторить команду: \(error)")
        }
    }
    
    func sendCommand(name: String, to childID: String) async throws -> String {
        let record = CKRecord(recordType: "Command")
        let recordID = record.recordID.recordName
        
        record["commandName"] = name as CKRecordValue
        record["targetChildID"] = childID as CKRecordValue
        record["createdAt"] = Date() as CKRecordValue
        record["status"] = "pending" as CKRecordValue
        record["senderDeviceID"] = getDeviceIdentifier() as CKRecordValue // ID устройства родителя
        
        try await container.publicCloudDatabase.save(record)
        print("✅ Команда '\(name)' отправлена ребенку \(childID)")
        
        let commandStatus = CommandStatus(
            recordID: recordID,
            commandName: name,
            targetChildID: childID,
            sentAt: Date(),
            status: .pending,
            updatedAt: Date(),
            lastChecked: Date(),
            attempts: 0
        )
        
        await MainActor.run {
            pendingCommands[recordID] = commandStatus
        }
        
        startSmartStatusTracking(for: recordID)
        
        return recordID
    }
    
    private func startSmartStatusTracking(for recordID: String) {
        Task {
            var attempts = 0
            let maxAttempts = 20
            while attempts < maxAttempts {
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                attempts += 1
                
                do {
                    let record = try await container.publicCloudDatabase.record(for: CKRecord.ID(recordName: recordID))
                    
                    if let statusString = record["status"] as? String,
                       let status = CommandStatus.Status(rawValue: statusString) {
                        
                        await updateCommandStatus(recordID: recordID, status: status, attempt: attempts)
                        
                        if status == .executed {
                            print("✅ Команда выполнена, отслеживание завершено")
                            scheduleRemoval(of: recordID, delay: 5)
                            break
                        }
                    }
                    
                } catch let error as CKError {
                    if error.code == .unknownItem {
                        print("📭 Запись команды \(recordID) удалена ребенком - считаем выполненной")
                        await updateCommandStatus(recordID: recordID, status: .notFound, attempt: attempts)
                        scheduleRemoval(of: recordID, delay: 3)
                        break
                    } else {
                        print("❌ Ошибка CloudKit: \(error)")
                        await updateCommandStatus(recordID: recordID, status: .failed, attempt: attempts)
                    }
                } catch {
                    print("❌ Ошибка проверки статуса: \(error)")
                    await updateCommandStatus(recordID: recordID, status: .failed, attempt: attempts)
                }
                
                if attempts >= maxAttempts {
                    await updateCommandStatus(recordID: recordID, status: .timeout, attempt: attempts)
                    scheduleRemoval(of: recordID, delay: 10)
                }
            }
        }
    }
    
    @MainActor
    private func updateCommandStatus(recordID: String, status: CommandStatus.Status, attempt: Int) {
        if var commandStatus = pendingCommands[recordID] {
            commandStatus.status = status
            commandStatus.updatedAt = Date()
            commandStatus.lastChecked = Date()
            commandStatus.attempts = attempt
            pendingCommands[recordID] = commandStatus
            
            print("🔄 Статус команды \(recordID) обновлен: \(status.rawValue) (попытка \(attempt))")
        }
    }
    
    private func scheduleRemoval(of recordID: String, delay: Int) {
        Task {
            try? await Task.sleep(nanoseconds: UInt64(delay) * 1_000_000_000)
            await MainActor.run {
                pendingCommands.removeValue(forKey: recordID)
                print("🧹 Команда \(recordID) удалена из отслеживания")
            }
        }
    }
    
    private func getDeviceIdentifier() -> String {
        return UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
    }
}

extension CloudKitManager {
    func fetchNewCommands() async {
        guard await AuthenticationManager.shared.userRole == .child else { return }
        
        print("🔍 АКТИВНАЯ проверка новых команд в \(Date())")
        
        guard let childID = await AuthenticationManager.shared.myUserRecordID else {
            print("❌ Не удалось получить ID ребенка")
            return
        }
        
        let lastCheckKey = "lastCommandCheckTimestamp_\(childID)"
        let lastCheck = UserDefaults.standard.double(forKey: lastCheckKey)
        let threeMinutesAgo = Date().addingTimeInterval(-3 * 60).timeIntervalSince1970
        
        if lastCheck > threeMinutesAgo {
            print("⏭️ Пропускаем проверку - последняя была менее 2 минут назад")
            return
        }
    
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: lastCheckKey)
        
        let predicate = NSPredicate(format: "targetChildID == %@", childID)
        let query = CKQuery(recordType: "Command", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        do {
            let results = try await publicDatabase.records(matching: query)
            print("✅ Найдено \(results.matchResults.count) команд для ребенка \(childID)")
            
            var foundNewCommands = false
            
            for (recordID, result) in results.matchResults {
                switch result {
                case .success(let record):
                    if let commandName = record["commandName"] as? String {
                        print("🆕 Найдена команда: \(commandName)")
                        
                        if !self.isCommandAlreadyExecuted(recordID: recordID) {
                            foundNewCommands = true
                            self.savePendingCommand(commandName: commandName, recordID: recordID)
                            await self.executeCommandInBackground(name: commandName, recordID: recordID)
                        }
                    }
                    
                case .failure(let error):
                    print("❌ Ошибка загрузки команды: \(error)")
                }
            }
            
            if !foundNewCommands {
                print("📭 Новых команд не найдено")
            }
            
        } catch {
            print("❌ Ошибка проверки новых команд: \(error)")
        }
    }
    
    private func isCommandAlreadyExecuted(recordID: CKRecord.ID) -> Bool {
        let executedCommandsKey = "executedCommands"
        var executedCommands = UserDefaults.standard.stringArray(forKey: executedCommandsKey) ?? []
        
        if executedCommands.contains(recordID.recordName) {
            print("⏭️ Команда \(recordID.recordName) уже выполнялась - пропускаем")
            return true
        }
        
        executedCommands.append(recordID.recordName)
        if executedCommands.count > 100 {
            executedCommands.removeFirst(50)
        }
        UserDefaults.standard.set(executedCommands, forKey: executedCommandsKey)
        
        return false
    }
    
    func processPendingCommands() async {
        guard await AuthenticationManager.shared.userRole == .child else { return }
        
        print("🔄 Обрабатываем ожидающие команды в \(Date())")
        
        // Проверяем pending команду
        if let pendingCommand = UserDefaults.standard.dictionary(forKey: "pendingCommand"),
           let commandName = pendingCommand["commandName"] as? String,
           let recordIDString = pendingCommand["recordID"] as? String {
            
            let recordID = CKRecord.ID(recordName: recordIDString)
            let attempts = pendingCommand["attempts"] as? Int ?? 1
            
            print("🎯 Выполняем ожидающую команду: \(commandName) (попытка \(attempts))")
            
            if attempts >= 5 {
                UserDefaults.standard.removeObject(forKey: "pendingCommand")
                print("🧹 Очищаем команду после 5 неудачных попыток")
                return
            }
            
            await self.executeCommandInBackground(name: commandName, recordID: recordID)
            
        } else {
            print("📭 Ожидающих команд нет")
        }
    }
}

extension CloudKitManager {
    func quickCommandCheck() async {
        guard await AuthenticationManager.shared.userRole == .child,
              let childID = await AuthenticationManager.shared.myUserRecordID else {
            return
        }
        
        let timeout: UInt64 = 10_000_000_000
        
        do {
            try await withThrowingTaskGroup(of: Void.self) { group in
                group.addTask {
                    try await Task.sleep(nanoseconds: timeout)
                    throw NSError(domain: "Timeout", code: -1, userInfo: nil)
                }
                
                group.addTask {
                    let fiveMinutesAgo = Date().addingTimeInterval(-5 * 60)
                    let predicate = NSPredicate(format: "targetChildID == %@ AND createdAt >= %@", childID, fiveMinutesAgo as CVarArg)
                    let query = CKQuery(recordType: "Command", predicate: predicate)
                    
                    let results = try await self.publicDatabase.records(matching: query, desiredKeys: ["commandName"])
                    
                    for (recordID, result) in results.matchResults {
                        if case .success(let record) = result,
                           let commandName = record["commandName"] as? String {
                            await self.executeCommandInBackground(name: commandName, recordID: recordID)
                        }
                    }
                }
                
                try await group.next()
                group.cancelAll()
            }
        } catch {

        }
    }
}
