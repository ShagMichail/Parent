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

class CloudKitManager: ObservableObject {
    static let shared = CloudKitManager()
    
    private let container = CKContainer.default()
    
    var publicDatabase: CKDatabase { container.publicCloudDatabase }
    
    
    // MARK: - Public Method
    
    func fetchUserRecordID() async -> String? {
        do {
            let recordID = try await container.userRecordID()
            return recordID.recordName
        } catch {
            print("🚨 CloudKitManager: Не удалось получить User Record ID: \(error)")
            return nil
        }
    }
    
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
        
        do {
            print("▶️ [Parent] Пытаемся сохранить подписку...")
            try await publicDatabase.save(subscription)
            print("✅ [Parent] Подписка на принятие приглашения успешно создана.")
        } catch {
            print("🛑 [Parent] КРИТИЧЕСКАЯ ОШИБКА: Не удалось сохранить подписку на приглашение: \(error)")
        }
    }

    /// ВЫЗЫВАЕТСЯ РОДИТЕЛЕМ для отправки команды.
    func sendCommand(name: String, to childID: String) async throws {
        let record = CKRecord(recordType: "Command")
        record["commandName"] = name as CKRecordValue
        record["targetChildID"] = childID as CKRecordValue
        record["status"] = CommandStatus.pending.rawValue as CKRecordValue
        record["createdAt"] = Date() as CKRecordValue
        
        do {
            print("▶️ [Parent] Пытаемся сохранить команду...")
            try await publicDatabase.save(record)
            print("✅ [Parent] Команда успешно создана.")
            print("✅ Command '\(name)' sent to \(childID) with status .pending")
        } catch {
            print("🛑 [Parent] КРИТИЧЕСКАЯ ОШИБКА: Не удалось сохранить команду: \(error)")
        }
    }
    
    /// ВЫЗЫВАЕТСЯ РЕБЕНКОМ для подписки на команды.
    func subscribeToCommands(for childID: String) async throws {
        let subscriptionID = "commands-for-user-\(childID)"
        do {
            try await publicDatabase.deleteSubscription(withID: subscriptionID)
            print("✅ [Child] Подписка удалена")
        } catch {
            print("🛑 ОШИБКА УДАЛЕНИЯ ПОДПИСКИ: \(error)")
        }
        
        let predicate = NSPredicate(format: "targetChildID == %@", childID)
        
        let subscription = CKQuerySubscription(
            recordType: "Command",
            predicate: predicate,
            subscriptionID: subscriptionID,
            options: .firesOnRecordCreation
        )
        
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.alertBody = "Обновление настроек и сбор информации"
        notificationInfo.shouldSendMutableContent = true
        notificationInfo.shouldSendContentAvailable = true
        notificationInfo.desiredKeys = ["commandName"]
        
        subscription.notificationInfo = notificationInfo
        
        do {
            try await publicDatabase.save(subscription)
            print("✅ [Child] Подписка обновлена: Visible + Mutable Content")
        } catch {
            print("🛑 ОШИБКА СОХРАНЕНИЯ ПОДПИСКИ: \(error)")
            
            if let ckError = error as? CKError {
                print("Code: \(ckError.code.rawValue)")
                
                if let partialErrors = ckError.partialErrorsByItemID {
                    print("Details (Partial Errors): \(partialErrors)")
                }
            }
        }
    }
    
    /// Очистка выполненных команд (вызывается родителем после успеха)
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
        
        do {
            try await publicDatabase.deleteSubscription(withID: subscriptionID)
            print("✅ [Parent] Подписка удалена command-updates")
        } catch {
            print("🛑 ОШИБКА УДАЛЕНИЯ ПОДПИСКИ: \(error)")
        }
        
        let predicate = NSPredicate(format: "targetChildID == %@", childID)
        
        let subscription = CKQuerySubscription(
            recordType: "Command",
            predicate: predicate,
            subscriptionID: subscriptionID,
            options: [.firesOnRecordUpdate]
        )
        
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        
        notificationInfo.desiredKeys = ["status", "commandName", "targetChildID"]
        
        subscription.notificationInfo = notificationInfo
        
        do {
            print("▶️ [Parent] Пытаемся сохранить команду...")
            try await publicDatabase.save(subscription)
            print("✅ [Parent] Подписались на обновления команд ребенка: \(childID)")
        } catch {
            print("🛑 [Parent] КРИТИЧЕСКАЯ ОШИБКА: Не удалось сохранить подписку на обновления команд ребенка: \(error)")
        }
    }
    
    /// РЕБЕНОК выполняет команду и обновляет статус
    func updateCommandStatus(recordID: CKRecord.ID, status: CommandStatus) async throws {
        // Сначала получаем свежую запись (CloudKit требует этого для update)
        let record = try await publicDatabase.record(for: recordID)
        record["status"] = status.rawValue as CKRecordValue
        
        do {
            print("▶️ [Child] Пытаемся обновить статус команды...")
            try await publicDatabase.save(record)
            print("✅ Child updated command status to: \(status.rawValue)")
        } catch {
            print("🛑 [Child] КРИТИЧЕСКАЯ ОШИБКА: Не удалось обновить статус команды: \(error)")
        }
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
        
        let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: false)
        
        let query = CKQuery(recordType: "Command", predicate: predicate)
        query.sortDescriptors = [sortDescriptor]
        
        let (matchResults, _) = try await publicDatabase.records(matching: query, resultsLimit: 1)
        
        return try matchResults.first?.1.get()
    }
}

extension CloudKitManager {
    /// РОДИТЕЛЬ сохраняет или обновляет расписание
    func saveFocusSchedule(_ schedule: FocusSchedule, for childID: String) async throws {
        let record = schedule.toRecord(childID: childID)
        let modifyOp = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        modifyOp.savePolicy = .changedKeys
        
        return try await withCheckedThrowingContinuation { continuation in
            modifyOp.modifyRecordsResultBlock = { result in
                switch result {
                case .success:
                    print("✅ CloudKit: Расписание сохранено для ребенка \(childID)")
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
            publicDatabase.add(modifyOp)
        }
    }
    
    /// РОДИТЕЛЬ удаляет расписание
    func deleteFocusSchedule(_ schedule: FocusSchedule) async throws {
        let recordID = CKRecord.ID(recordName: schedule.recordID ?? schedule.id.uuidString)
        try await publicDatabase.deleteRecord(withID: recordID)
        print("🗑 CloudKit: Расписание удалено")
    }
    
    /// РЕБЕНОК подписывается на изменения расписания (вызвать 1 раз при входе)
    func subscribeToScheduleChanges(for childID: String) async throws {
        let subscriptionID = "focus-schedules-\(childID)"
        do {
            try await publicDatabase.deleteSubscription(withID: subscriptionID)
            print("✅ [Child] Подписка удалена focus-schedules")
        } catch {
            print("🛑 ОШИБКА УДАЛЕНИЯ ПОДПИСКИ: \(error)")
        }
        
        let predicate = NSPredicate(format: "targetChildID == %@", childID)
        
        let subscription = CKQuerySubscription(
            recordType: "FocusSchedule",
            predicate: predicate,
            subscriptionID: subscriptionID,
            options: [.firesOnRecordCreation, .firesOnRecordUpdate, .firesOnRecordDeletion]
        )
        
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.alertBody = "Расписание было обновлено"
        notificationInfo.shouldSendMutableContent = true
        notificationInfo.shouldSendContentAvailable = true
        
        notificationInfo.desiredKeys = ["startTimeString", "endTimeString", "daysOfWeekString", "isEnabled"]
        
        subscription.notificationInfo = notificationInfo
        
        do {
            print("▶️ [Child] Пытаемся сохранить подписку...")
            try await publicDatabase.save(subscription)
            print("✅ [Child] Подписка на изменения расписаний успешно создана.")
        } catch {
            print("🛑 [Child] КРИТИЧЕСКАЯ ОШИБКА: Не удалось сохранить подписку: \(error)")
        }
    }
    
    /// РЕБЕНОК скачивает все свои актуальные расписания
    func fetchSchedules(for childID: String) async throws -> [FocusSchedule] {
        let predicate = NSPredicate(format: "targetChildID == %@", childID)
        let query = CKQuery(recordType: "FocusSchedule", predicate: predicate)
        
        let (matchResults, _) = try await publicDatabase.records(matching: query)
        
        let schedules: [FocusSchedule] = matchResults.compactMap { _, result in
            guard let record = try? result.get() else { return nil }
            return FocusSchedule(record: record)
        }
        
        return schedules
    }
}

extension CloudKitManager {
    /// ОТПРАВКА (Вызывается с устройства ребенка)
    func sendDeviceStatus(_ status: ChildDeviceStatus) async throws {
        guard let myRecordIDString = await fetchUserRecordID() else { return }
        
        let record = CKRecord(recordType: "DeviceStatus")
        
        record["location"] = status.location
        record["batteryLevel"] = status.batteryLevel
        record["batteryState"] = status.batteryState
        record["timestamp"] = status.timestamp
        
        let userRecordID = CKRecord.ID(recordName: myRecordIDString)
        record["userRef"] = CKRecord.Reference(recordID: userRecordID, action: .none)
        
        try await publicDatabase.save(record)
        print("📡 CloudKit: Новая точка DeviceStatus сохранена.")
    }
    
    /// ПОЛУЧЕНИЕ (Вызывается с устройства родителя)
    func fetchLocationHistory(for childID: String, limit: Int = 100) async throws -> [CLLocation] {
        let childRecordID = CKRecord.ID(recordName: childID)
        let reference = CKRecord.Reference(recordID: childRecordID, action: .none)
        
        let predicate = NSPredicate(format: "userRef == %@", reference)
        
        let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
        
        let query = CKQuery(recordType: "DeviceStatus", predicate: predicate)
        query.sortDescriptors = [sortDescriptor]
        
        let (matchResults, _) = try await publicDatabase.records(matching: query, resultsLimit: limit)
        
        let locations: [CLLocation] = matchResults.compactMap { _, result in
            guard let record = try? result.get(),
                  let location = record["location"] as? CLLocation else {
                return nil
            }
            return location
        }
        
        return locations
    }
}

extension CloudKitManager {
    func fetchExistingChildren() async throws -> [Child] {
        guard let parentID = await fetchUserRecordID() else { return [] }
        
        let predicate = NSPredicate(format: "parentUserRecordID == %@ AND childUserRecordID != %@", parentID, "nil")
        let query = CKQuery(recordType: "Invitation", predicate: predicate)
        
        let (matchResults, _) = try await publicDatabase.records(matching: query)
        
        var children: [Child] = []
        
        for (_, result) in matchResults {
            if let record = try? result.get() {
                if let childID = record["childUserRecordID"] as? String,
                   let name = record["childName"] as? String {
                    
                    children.append(Child(id: UUID(uuidString: childID) ?? UUID(), name: name, recordID: childID))
                }
            }
        }
        
        print("👨‍👩‍👧 CloudKit: Найдено \(children.count) существующих детей.")
        return children
    }
    
    /// ПОЛУЧЕНИЕ (Вызывается с устройства родителя)
    func fetchDeviceStatus(for childID: String) async throws -> (batteryLevel: Float, batteryState: String, lastSeen: Date, location: CLLocation?)? {
        
        let childRecordID = CKRecord.ID(recordName: childID)
        let reference = CKRecord.Reference(recordID: childRecordID, action: .none)
        
        let predicate = NSPredicate(format: "userRef == %@", reference)
        
        let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
        
        let query = CKQuery(recordType: "DeviceStatus", predicate: predicate)
        query.sortDescriptors = [sortDescriptor]
        
        do {
            let (matchResults, _) = try await publicDatabase.records(matching: query, resultsLimit: 1)
            
            guard let record = try matchResults.first?.1.get() else {
                print("ℹ️ Статус для ребенка \(childID) пока не найден.")
                return nil
            }
            
            guard let level = record["batteryLevel"] as? Double,
                  let state = record["batteryState"] as? String,
                  let timestamp = record["timestamp"] as? Date else { // Используем 'timestamp'
                print("⚠️ Запись статуса для \(childID) повреждена.")
                return nil
            }
            
            let location = record["location"] as? CLLocation
            
            return (Float(level), state, timestamp, location)
            
        } catch {
            print("❌ Ошибка при поиске статуса для ребенка \(childID): \(error.localizedDescription)")
            throw error
        }
    }
}
