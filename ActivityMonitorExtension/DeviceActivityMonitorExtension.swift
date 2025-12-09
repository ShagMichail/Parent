//
//  DeviceActivityMonitorExtension.swift
//  ActivityMonitorExtension
//
//  Created by Михаил Шаговитов on 03.12.2025.
//

import DeviceActivity
import ManagedSettings
import CloudKit
import FamilyControls

// Убедись, что этот класс наследуется от DeviceActivityMonitor
class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    
    let store = ManagedSettingsStore()
    let database = CKContainer(identifier: "iCloud.com.laborato.Parent").publicCloudDatabase // ⚠️ ВСТАВЬ СВОЙ ID КОНТЕЙНЕРА
    let appGroup = "group.com.laborato.test.Parent" // ⚠️ ВСТАВЬ СВОЮ ГРУППУ
    
    // Этот метод вызывается, когда начинается расписание мониторинга
    // (например, при перезагрузке телефона или старте приложения)
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        print("MONITOR: Интервал начался. Проверяем команды...")
        
        checkCloudKitForPendingCommands()
    }
    
    // Этот метод вызывается периодически системой (не гарантировано по времени, но происходит)
    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
        // Тоже можно проверить команды
        checkCloudKitForPendingCommands()
    }
    
    private func checkCloudKitForPendingCommands() {
        // 1. Получаем ID ребенка из общей памяти
        guard let defaults = UserDefaults(suiteName: appGroup),
              let childID = defaults.string(forKey: "myChildRecordID") else {
            print("MONITOR: Child ID не найден в UserDefaults")
            return
        }
        
        // 2. Ищем команды со статусом "pending"
        let predicate = NSPredicate(format: "targetChildID == %@ AND status == %@", childID, "pending")
        let query = CKQuery(recordType: "Command", predicate: predicate)
        
        // Сортируем, берем последнюю
        query.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        let operation = CKQueryOperation(query: query)
        operation.resultsLimit = 1
        
        operation.recordMatchedBlock = { recordID, result in
            switch result {
            case .success(let record):
                self.handleRecord(record)
            case .failure(let error):
                print("MONITOR: Ошибка получения записи: \(error)")
            }
        }
        
        database.add(operation)
    }
    
    private func handleRecord(_ record: CKRecord) {
        guard let commandName = record["commandName"] as? String else { return }
        print("MONITOR: Найдена команда \(commandName)")
        
        // 3. Выполняем блокировку (ManagedSettings работает в расширении!)
        // Важно: ManagedSettingsStore применяет настройки к устройству, даже если само приложение мертво.
        if commandName == "block_all" {
            store.shield.applicationCategories = .all()
            // store.shield.webDomains = .all()
        } else if commandName == "unblock_all" {
            store.shield.applicationCategories = nil
            store.shield.webDomains = nil
        }
        
        // 4. Обновляем статус в CloudKit
        record["status"] = "executed"
        
        let modifyOp = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        modifyOp.savePolicy = .changedKeys
        modifyOp.modifyRecordsResultBlock = { result in
             print("MONITOR: Статус обновлен на executed")
        }
        
        database.add(modifyOp)
    }
}
