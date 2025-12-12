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

extension CloudKitManager {
    
    // MARK: - Focus Schedule Flow (Parent Side)
    
    /// 1. РОДИТЕЛЬ сохраняет или обновляет расписание
    func saveFocusSchedule(_ schedule: FocusSchedule, for childID: String) async throws {
        let record = schedule.toRecord(childID: childID)
        // .allKeys сохраняет перезаписывая все поля (Update)
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
    
    /// 2. РОДИТЕЛЬ удаляет расписание
    func deleteFocusSchedule(_ schedule: FocusSchedule) async throws {
        let recordID = CKRecord.ID(recordName: schedule.recordID ?? schedule.id.uuidString)
        try await publicDatabase.deleteRecord(withID: recordID)
        print("🗑 CloudKit: Расписание удалено")
    }
    
    // MARK: - Focus Schedule Flow (Child Side)
    
    /// 3. РЕБЕНОК подписывается на изменения расписания (вызвать 1 раз при входе)
    func subscribeToScheduleChanges(for childID: String) async throws {
        let subscriptionID = "focus-schedules-\(childID)"
        
        let predicate = NSPredicate(format: "targetChildID == %@", childID)
        
        // Подписываемся на ВСЕ: создание, обновление, удаление
        let subscription = CKQuerySubscription(
            recordType: "FocusSchedule",
            predicate: predicate,
            subscriptionID: subscriptionID,
            options: [.firesOnRecordCreation, .firesOnRecordUpdate, .firesOnRecordDeletion]
        )
        
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.shouldSendContentAvailable = true // Тихий пуш
        
        subscription.notificationInfo = notificationInfo
        
        // Игнорируем ошибку "уже существует"
        let operation = CKModifySubscriptionsOperation(subscriptionsToSave: [subscription], subscriptionIDsToDelete: nil)
        operation.modifySubscriptionsResultBlock = { _ in }
        
        publicDatabase.add(operation)
        print("✅ [Child] Подписались на изменения расписаний")
    }
    
    /// 4. РЕБЕНОК скачивает все свои актуальные расписания
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
    
    // MARK: - Device Status (Separate Record Type)
    
    /// ОТПРАВКА (Вызывается с устройства ребенка)
    func sendDeviceStatus(_ status: ChildDeviceStatus) async throws {
        // 1. Получаем ID текущего пользователя (Ребенка)
        guard let myRecordIDString = await fetchUserRecordID() else { return }
        
        // 2. Генерируем ID для записи статуса на основе ID ребенка.
        // Это гарантирует, что у одного ребенка всегда будет только ОДНА запись статуса,
        // которую мы будем перезаписывать (Upsert).
        let statusRecordID = CKRecord.ID(recordName: "status_\(myRecordIDString)")
        
        // 3. Создаем запись с типом "DeviceStatus"
        let record = CKRecord(recordType: "DeviceStatus", recordID: statusRecordID)
        
        // 4. Заполняем поля
        record["location"] = status.location
        record["batteryLevel"] = status.batteryLevel
        record["batteryState"] = status.batteryState
        record["lastSeen"] = status.timestamp
        // Добавляем ссылку на ребенка (для порядка в базе), хотя ищем мы по ID
        record["userRef"] = CKRecord.Reference(recordID: CKRecord.ID(recordName: myRecordIDString), action: .deleteSelf)
        
        // 5. Сохраняем (Upsert - Обновить или Создать)
        // Используем .allKeys, чтобы полностью перезаписать состояние новой информацией
        let modifyOp = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        modifyOp.savePolicy = .allKeys
        
        return try await withCheckedThrowingContinuation { continuation in
            modifyOp.modifyRecordsResultBlock = { result in
                switch result {
                case .success:
                    print("📡 CloudKit: DeviceStatus обновлен (отдельная таблица)")
                    continuation.resume()
                case .failure(let error):
                    print("❌ Ошибка отправки DeviceStatus: \(error)")
                    continuation.resume(throwing: error)
                }
            }
            publicDatabase.add(modifyOp)
        }
    }
    
    /// ПОЛУЧЕНИЕ (Вызывается с устройства родителя)
    func fetchDeviceStatus(for childID: String) async throws -> (batteryLevel: Float, batteryState: String, lastSeen: Date, location: CLLocation?)? {
        
        // 1. Мы знаем ID ребенка, значит знаем и ID его статуса
        let statusRecordID = CKRecord.ID(recordName: "status_\(childID)")
        
        do {
            // 2. Пытаемся скачать конкретную запись
            let record = try await publicDatabase.record(for: statusRecordID)
            
            guard let level = record["batteryLevel"] as? Double,
                  let state = record["batteryState"] as? String,
                  let lastSeen = record["lastSeen"] as? Date else {
                return nil
            }
            
            let location = record["location"] as? CLLocation
            
            return (Float(level), state, lastSeen, location)
            
        } catch {
            // Если записи нет (ребенок еще ни разу не отправлял статус)
            print("⚠️ Статус для ребенка \(childID) не найден: \(error.localizedDescription)")
            return nil
        }
    }
}
