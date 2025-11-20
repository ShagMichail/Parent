//
//  CloudKitManager.swift
//  Parent
//
//  Created by Михаил Шаговитов on 17.11.2025.
//

import Foundation
import CloudKit
import Combine

protocol CloudKitCommandReceiver: AnyObject {
    func executeCommand(_ commandName: String)
}

class CloudKitManager {
    static let shared = CloudKitManager()
    
    weak var commandReceiver: CloudKitCommandReceiver?
    
    private let container = CKContainer.default()
    private var privateDatabase: CKDatabase { container.privateCloudDatabase }
    
    
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
        
        let record = CKRecord(recordType: "Invitation")
        record["invitationCode"] = invitationCode as CKRecordValue
        record["childUserRecordID"] = childID as CKRecordValue
        record["createdAt"] = Date() as CKRecordValue
        
        try await privateDatabase.save(record)
        print("✅ Приглашение с кодом \(invitationCode) создано.")
        return invitationCode
    }
    
    func acceptInvitation(withCode code: String) async throws -> String {
        let predicate = NSPredicate(format: "invitationCode == %@", code)
        let query = CKQuery(recordType: "Invitation", predicate: predicate)
        
        let (matchResults, _) = try await privateDatabase.records(matching: query)
        
        guard let record = matchResults.first?.1,
              let result = try? record.get(),
              let childID = result["childUserRecordID"] as? String else {
            throw NSError(domain: "CloudKitManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "Код не найден или истек"])
        }
        
        try await privateDatabase.deleteRecord(withID: result.recordID)
        
        print("✅ Приглашение принято! ID ребенка: \(childID)")
        return childID
    }
    
    func sendCommand(name: String, to childID: String) async throws {
        let record = CKRecord(recordType: "Command")
        record["commandName"] = name as CKRecordValue
        record["targetChildID"] = childID as CKRecordValue
        record["timestamp"] = Date().timeIntervalSince1970 as CKRecordValue
        
        try await privateDatabase.save(record)
        print("✅ Команда '\(name)' успешно отправлена в CloudKit.")
    }
    
    func subscribeToCommands(for childID: String) async throws {
        let subscriptions = try await privateDatabase.allSubscriptions()
        for sub in subscriptions {
            try await privateDatabase.deleteSubscription(withID: sub.subscriptionID)
        }
        
        let predicate = NSPredicate(format: "targetChildID == %@", childID)
        let subscription = CKQuerySubscription(
            recordType: "Command",
            predicate: predicate,
            options: .firesOnRecordCreation
        )
        
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        subscription.notificationInfo = notificationInfo
        
        try await privateDatabase.save(subscription)
        print("✅ Успешно подписались на команды для ребенка \(childID).")
    }
    
    func handleRemoteNotification(userInfo: [AnyHashable: Any]) {
        if let notification = CKQueryNotification(fromRemoteNotificationDictionary: userInfo) {
            guard let recordID = notification.recordID else { return }
            
            Task {
                do {
                    let record = try await privateDatabase.record(for: recordID)
                    if let commandName = record["commandName"] as? String {
                        print("📬 Получена команда через push: \(commandName)")
                        await MainActor.run {
                            commandReceiver?.executeCommand(commandName)
                        }
                    }
                } catch {
                    print("🚨 Не удалось загрузить запись из CloudKit: \(error)")
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
            try await privateDatabase.save(testRecord)
            print("--- ✅✅✅ [Этап 2] СУПЕР-УСПЕХ! Тестовая запись успешно сохранена.")
            print("--- Это означает, что ваше приложение имеет полные права на чтение/запись в контейнер.")
            
            try await privateDatabase.deleteRecord(withID: testRecord.recordID)
            print("--- (Тестовая запись успешно удалена)")
            
        } catch {
            print("--- ❌❌❌ [Этап 2] ПРОВАЛ! Получена ошибка при сохранении тестовой записи. Вот она:")
            print("--- \(error)")
            print("--- Если это ошибка 'Permission Failure', то проблема 100% в несоответствии Bundle ID и контейнера.")
        }
        print("--- ✅ ПРОВЕРКА ПОДКЛЮЧЕНИЯ ЗАВЕРШЕНА ---")
    }
}
