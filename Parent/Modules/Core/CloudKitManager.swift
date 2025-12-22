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
import ManagedSettings

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
//    func sendCommand(name: String, to childID: String, payload: [String: Any]? = nil) async throws {
        func sendCommand(name: String, to childID: String) async throws {
        let record = CKRecord(recordType: "Command")
        record["commandName"] = name as CKRecordValue
        record["targetChildID"] = childID as CKRecordValue
        record["status"] = CommandStatus.pending.rawValue as CKRecordValue
        record["createdAt"] = Date() as CKRecordValue
        
//        if let payload = payload {
//            record["payload"] = try NSKeyedArchiver.archivedData(withRootObject: payload, requiringSecureCoding: false) as CKRecordValue
//        }
        
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
//        notificationInfo.desiredKeys = ["commandName", "payload"]
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
    
    func fetchLatestBlockCommand(for childID: String) async throws -> CKRecord? {
        // Ищем записи, где childID совпадает И (имя = block_all ИЛИ имя = unblock_all)
        let predicate = NSPredicate(
            format: "targetChildID == %@ AND commandName IN %@",
            childID,
            ["block_all", "unblock_all"]
        )
        
        // Сортируем: самые новые сверху
        let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: false)
        
        let query = CKQuery(recordType: "Command", predicate: predicate)
        query.sortDescriptors = [sortDescriptor]
        
        // Берем только одну (самую свежую)
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
        
        do {
            print("▶️ [Child] Пытаемся сохранить статус...")
            try await publicDatabase.save(record)
            print("✅ [Child] Статус успешно сохранен.")
            await markPendingLocationCommandAsExecuted()
        } catch {
            print("🛑 [Child] КРИТИЧЕСКАЯ ОШИБКА: Не удалось сохранить статус: \(error)")
        }
    }
    
    private func markPendingLocationCommandAsExecuted() async {
        guard let childID = await fetchUserRecordID() else { return }
        
        // 1. Ищем команду: Для МЕНЯ (childID), имя = запрос локации, статус = ожидание
        let predicate = NSPredicate(
            format: "targetChildID == %@ AND commandName IN %@ AND status IN %@",
            childID,
            ["request_location_update"],
            ["pending"]
        )
        
        let query = CKQuery(recordType: "Command", predicate: predicate)
        // Сортируем: старые первыми (чтобы закрыть самую давнюю) или новые первыми
        query.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        do {
            // 2. Запрашиваем запись
            let (matchResults, _) = try await publicDatabase.records(matching: query, resultsLimit: 1)
            
            // Если нашли висящую команду
            if let record = try? matchResults.first?.1.get() {
                print("📍 CloudKit: Найдена висящая команда локации. Закрываем...")
                
                // 3. Меняем статус
                record["status"] = "executed"
                
                // 4. Сохраняем изменение
                let modifyOp = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
                modifyOp.savePolicy = .changedKeys
                
                try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                    modifyOp.modifyRecordsResultBlock = { result in
                        switch result {
                        case .success:
                            print("✅ CloudKit: Команда локации помечена как EXECUTED")
                            continuation.resume()
                        case .failure(let error):
                            continuation.resume(throwing: error)
                        }
                    }
                    publicDatabase.add(modifyOp)
                }
            }
        } catch {
            print("⚠️ Не удалось закрыть команду локации: \(error)")
        }
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

extension CloudKitManager {
    /// РОДИТЕЛЬ: Сохраняет массив отдельных лимитов
    func saveAppLimits(_ limits: [AppLimit], for childID: String) async throws {
        let predicate = NSPredicate(format: "targetChildID == %@", childID)
        let query = CKQuery(recordType: "AppLimit", predicate: predicate)
        let (matchResults, _) = try await publicDatabase.records(matching: query)
        let serverRecordIDs = Set(matchResults.map { $0.0 })
        
        // --- Шаг 1: Превращаем наши UI-модели в записи CloudKit ---
        let recordsToSave: [CKRecord] = limits.compactMap { limit in
            let tokenData: Data
            do {
                tokenData = try JSONEncoder().encode(limit.token)
            } catch {
                print("⚠️ Не удалось закодировать токен. Пропускаем. Ошибка: \(error)")
                return nil
            }
            
            // ✅ ИСПРАВЛЕНИЕ 2: Используем хеш от Data как уникальный идентификатор
            let tokenHash = tokenData.sha256
            
            // Формируем чистый и уникальный recordName
            let recordName = "limit_\(childID)_\(tokenHash)"
            let recordID = CKRecord.ID(recordName: recordName)
            let record = CKRecord(recordType: "AppLimit", recordID: recordID)
            
            record["targetChildID"] = childID as CKRecordValue
            record["appTokenData"] = tokenData as CKRecordValue
            record["timeLimit"] = limit.time as CKRecordValue
            
            return record
        }
        let localRecordIDs = Set(recordsToSave.map { $0.recordID })
        
        // --- Шаг 3: Определяем, какие записи нужно удалить с сервера ---
        // (Те, что есть на сервере, но которых нет в локальном списке)
        let recordIDsToDelete = Array(serverRecordIDs.subtracting(localRecordIDs))
        
        // --- Шаг 4: Выполняем единую операцию ---
        print("🔄 Синхронизация лимитов: Сохранить/Обновить - \(recordsToSave.count), Удалить - \(recordIDsToDelete.count)")
        
        // Если нечего менять, выходим
        if recordsToSave.isEmpty && recordIDsToDelete.isEmpty {
            print("ℹ️ Нет изменений для синхронизации.")
            return
        }

        // --- Шаг 2: Используем операцию для сохранения/обновления всех записей разом ---
        let modifyOperation = CKModifyRecordsOperation(recordsToSave: recordsToSave, recordIDsToDelete: recordIDsToDelete)
        
        // Эта политика критически важна: она создает запись, если ее нет,
        // или полностью перезаписывает, если она уже существует.
        modifyOperation.savePolicy = .allKeys
        
        print("☁️ Отправка в CloudKit: \(recordsToSave.count) лимитов...")

        // --- Шаг 3: Выполняем операцию и ждем результата ---
        return try await withCheckedThrowingContinuation { continuation in
            modifyOperation.modifyRecordsResultBlock = { result in
                switch result {
                case .success:
                    // Успешное завершение всей операции
                    continuation.resume()
                case .failure(let error):
                    // Завершение операции с ошибкой
                    continuation.resume(throwing: error)
                }
            }
            
            // Добавляем операцию в очередь для выполнения
            publicDatabase.add(modifyOperation)
        }
    }
    
    /// РЕБЕНОК: Подписывается на создание, обновление и удаление лимитов
    func subscribeToAppLimitsChanges(for childID: String) async throws {
        let subscriptionID = "app-limits-updates-\(childID)"
        
        // Удаляем старую подписку, чтобы всегда иметь актуальную
        try? await publicDatabase.deleteSubscription(withID: subscriptionID)
        
        // Предикат: слушать изменения только для записей, предназначенных этому ребенку
//        let predicate = NSPredicate(format: "targetChildID == %@", childID)
        let predicate = NSPredicate(format: "targetChildID == %@ AND signalType == 'limits'", childID)
        let subscription = CKQuerySubscription(
            recordType: "ConfigSignal", // Следим за типом записи AppLimit
            predicate: predicate,
            subscriptionID: subscriptionID,
            // Реагируем на все возможные изменения
            options: [.firesOnRecordUpdate]
        )
        
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.alertBody = "Настройки лимитов были обновлены родителем."
        // 2. Устанавливаем флаг, который заставит систему разбудить наше РАСШИРЕНИЕ
        notificationInfo.shouldSendMutableContent = true
        subscription.notificationInfo = notificationInfo
        
        try await publicDatabase.save(subscription)
        print("✅ [Child] Успешно подписан на обновления лимитов.")
    }
    
    // ✅ НОВАЯ ФУНКЦИЯ: Загружает все лимиты для ребенка
    func fetchAppLimits(for childID: String) async throws -> [AppLimit] {
        print("☁️ Загрузка существующих лимитов для ребенка: \(childID)...")
        
        let predicate = NSPredicate(format: "targetChildID == %@", childID)
        let query = CKQuery(recordType: "AppLimit", predicate: predicate)
        
        let (matchResults, _) = try await publicDatabase.records(matching: query)
        
        // Превращаем записи CKRecord обратно в нашу модель AppLimit
        let limits: [AppLimit] = try matchResults.compactMap { _, result in
            let record = try result.get()
            
            guard let tokenData = record["appTokenData"] as? Data,
                  let timeLimit = record["timeLimit"] as? TimeInterval,
                  // Раскодируем токен из Data
                  let token = try? JSONDecoder().decode(ApplicationToken.self, from: tokenData)
            else {
                print("⚠️ Пропускаем поврежденную запись лимита.")
                return nil
            }
            
            return AppLimit(token: token, time: timeLimit)
        }
        
        print("✅ Загружено \(limits.count) лимитов.")
        return limits
    }
}

import Foundation
import CryptoKit // Фреймворк Apple для криптографии

extension Data {
    /// Вычисляет хеш SHA256 и возвращает его в виде строки.
    var sha256: String {
        let hash = SHA256.hash(data: self)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
}


extension CloudKitManager {
    /// РОДИТЕЛЬ: Сохраняет массив отдельных лимитов
    func saveAppBlocks(_ limits: [AppBlock], for childID: String) async throws {
        let predicate = NSPredicate(format: "targetChildID == %@", childID)
        let query = CKQuery(recordType: "AppBlock", predicate: predicate)
        let (matchResults, _) = try await publicDatabase.records(matching: query)
        let serverRecordIDs = Set(matchResults.map { $0.0 })
        
        // --- Шаг 1: Превращаем наши UI-модели в записи CloudKit ---
        let recordsToSave: [CKRecord] = limits.compactMap { limit in
            let tokenData: Data
            do {
                tokenData = try JSONEncoder().encode(limit.token)
            } catch {
                print("⚠️ Не удалось закодировать токен. Пропускаем. Ошибка: \(error)")
                return nil
            }
            
            // ✅ ИСПРАВЛЕНИЕ 2: Используем хеш от Data как уникальный идентификатор
            let tokenHash = tokenData.sha256
            
            // Формируем чистый и уникальный recordName
            let recordName = "block_\(childID)_\(tokenHash)"
            let recordID = CKRecord.ID(recordName: recordName)
            let record = CKRecord(recordType: "AppBlock", recordID: recordID)
            
            record["targetChildID"] = childID as CKRecordValue
            record["appTokenData"] = tokenData as CKRecordValue
            
            return record
        }
        let localRecordIDs = Set(recordsToSave.map { $0.recordID })
        
        // --- Шаг 3: Определяем, какие записи нужно удалить с сервера ---
        // (Те, что есть на сервере, но которых нет в локальном списке)
        let recordIDsToDelete = Array(serverRecordIDs.subtracting(localRecordIDs))
        
        // --- Шаг 4: Выполняем единую операцию ---
        print("🔄 Синхронизация блокировок: Сохранить/Обновить - \(recordsToSave.count), Удалить - \(recordIDsToDelete.count)")
        
        // Если нечего менять, выходим
        if recordsToSave.isEmpty && recordIDsToDelete.isEmpty {
            print("ℹ️ Нет изменений для синхронизации.")
            return
        }

        // --- Шаг 2: Используем операцию для сохранения/обновления всех записей разом ---
        let modifyOperation = CKModifyRecordsOperation(recordsToSave: recordsToSave, recordIDsToDelete: recordIDsToDelete)
        
        // Эта политика критически важна: она создает запись, если ее нет,
        // или полностью перезаписывает, если она уже существует.
        modifyOperation.savePolicy = .allKeys
        
        print("☁️ Отправка в CloudKit: \(recordsToSave.count) блокирововк...")

        // --- Шаг 3: Выполняем операцию и ждем результата ---
        return try await withCheckedThrowingContinuation { continuation in
            modifyOperation.modifyRecordsResultBlock = { result in
                switch result {
                case .success:
                    // Успешное завершение всей операции
                    continuation.resume()
                case .failure(let error):
                    // Завершение операции с ошибкой
                    continuation.resume(throwing: error)
                }
            }
            
            // Добавляем операцию в очередь для выполнения
            publicDatabase.add(modifyOperation)
        }
    }
    
    // Функция подписки на `AppLimit` остается концептуально такой же,
    // просто меняется recordType на "AppLimit".
    
    /// РЕБЕНОК: Подписывается на создание, обновление и удаление лимитов
    func subscribeToAppBlocksChanges(for childID: String) async throws {
        let subscriptionID = "app-block-updates-\(childID)"
        
        // Удаляем старую подписку, чтобы всегда иметь актуальную
        try? await publicDatabase.deleteSubscription(withID: subscriptionID)
        
        // Предикат: слушать изменения только для записей, предназначенных этому ребенку
//        let predicate = NSPredicate(format: "targetChildID == %@", childID)
        
        let predicate = NSPredicate(format: "targetChildID == %@ AND signalType == 'blocks'", childID)
        
        let subscription = CKQuerySubscription(
            recordType: "ConfigSignal", // Следим за типом записи AppLimit
            predicate: predicate,
            subscriptionID: subscriptionID,
            // Реагируем на все возможные изменения
            options: [.firesOnRecordUpdate]
        )
        
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.alertBody = "Настройки блокировок были обновлены родителем."
        // 2. Устанавливаем флаг, который заставит систему разбудить наше РАСШИРЕНИЕ
        notificationInfo.shouldSendMutableContent = true
        subscription.notificationInfo = notificationInfo
        
        try await publicDatabase.save(subscription)
        print("✅ [Child] Успешно подписан на обновления блокировок.")
    }
    
    // ✅ НОВАЯ ФУНКЦИЯ: Загружает все лимиты для ребенка
    func fetchAppBlocks(for childID: String) async throws -> [AppBlock] {
        print("☁️ Загрузка существующих блокирововк для ребенка: \(childID)...")
        
        let predicate = NSPredicate(format: "targetChildID == %@", childID)
        let query = CKQuery(recordType: "AppBlock", predicate: predicate)
        
        let (matchResults, _) = try await publicDatabase.records(matching: query)
        
        // Превращаем записи CKRecord обратно в нашу модель AppLimit
        let blocks: [AppBlock] = try matchResults.compactMap { _, result in
            let record = try result.get()
            
            guard let tokenData = record["appTokenData"] as? Data,
                  // Раскодируем токен из Data
                  let token = try? JSONDecoder().decode(ApplicationToken.self, from: tokenData)
            else {
                print("⚠️ Пропускаем поврежденную запись лимита.")
                return nil
            }
            
            return AppBlock(token: token)
        }
        
        print("✅ Загружено \(blocks.count) лимитов.")
        return blocks
    }
}


extension CloudKitManager {
    /// "Дергает" сигнальную запись, чтобы отправить один пуш ребенку.
    func triggerLimitsUpdateSignal(for childID: String) async throws {
        let recordID = CKRecord.ID(recordName: "signal_\(childID)")
        let record = CKRecord(recordType: "ConfigSignal", recordID: recordID)
        
        record["targetChildID"] = childID as CKRecordValue
        record["lastUpdate"] = Date() as CKRecordValue
        // ✅ УСТАНАВЛИВАЕМ ТИП СИГНАЛА
        record["signalType"] = "limits" as CKRecordValue
        
        // Используем операцию с .allKeys для создания/обновления
        let modifyOp = CKModifyRecordsOperation(recordsToSave: [record])
        modifyOp.savePolicy = .allKeys

        return try await withCheckedThrowingContinuation { continuation in
            modifyOp.modifyRecordsResultBlock = { result in
                switch result {
                case .success:
                    print("✅ Сигнал на обновление ЛИМИТОВ отправлен.")
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
            publicDatabase.add(modifyOp)
        }
    }
    
    /// "Дергает" сигнальную запись, чтобы отправить один пуш ребенку.
    func triggerBlocksUpdateSignal(for childID: String) async throws {
        let recordID = CKRecord.ID(recordName: "signal_\(childID)")
        let record = CKRecord(recordType: "ConfigSignal", recordID: recordID)

        record["targetChildID"] = childID as CKRecordValue
        record["lastUpdate"] = Date() as CKRecordValue
        // ✅ УСТАНАВЛИВАЕМ ТИП СИГНАЛА
        record["signalType"] = "blocks" as CKRecordValue
        
        let modifyOp = CKModifyRecordsOperation(recordsToSave: [record])
        modifyOp.savePolicy = .allKeys
//        // ... (оборачиваем в Continuation) ...
//        print("✅ Сигнал на обновление БЛОКИРОВОК отправлен.")
//        
        return try await withCheckedThrowingContinuation { continuation in
            modifyOp.modifyRecordsResultBlock = { result in
                switch result {
                case .success:
                    print("✅ Сигнал на обновление БЛОКИРОВОК отправлен.")
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
            publicDatabase.add(modifyOp)
        }
    }
}
