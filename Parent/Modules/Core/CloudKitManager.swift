//
//  CloudKitManager.swift
//  Parent
//
//  Created by Михаил Шаговитов on 17.11.2025.
//

import Foundation
import CloudKit
import Combine

protocol CloudKitCommandExecutor: AnyObject {
    func executeCommand(name: String, recordID: CKRecord.ID)
}

class CloudKitManager {
    static let shared = CloudKitManager()
    
    weak var commandExecutor: CloudKitCommandExecutor?
    
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
    
    func sendCommand(name: String, to childID: String) async throws {
        let record = CKRecord(recordType: "Command")
        record["commandName"] = name as CKRecordValue
        record["targetChildID"] = childID as CKRecordValue
        record["createdAt"] = Date() as CKRecordValue
        
        try await container.publicCloudDatabase.save(record)
        print("✅ Команда '\(name)' отправлена ребенку \(childID)")
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
}
