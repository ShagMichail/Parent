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

struct CachedFocusSchedule: Codable {
    let id: UUID
    let startTime: Date
    let endTime: Date
    let daysOfWeek: [CachedWeekday] // Используем упрощенный enum или Int
    let isEnabled: Bool
    
    // Зеркало вашего Enum Weekday для Codable совместимости
    enum CachedWeekday: Int, Codable {
        case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday
    }
}

// Убедись, что этот класс наследуется от DeviceActivityMonitor
//class DeviceActivityMonitorExtension: DeviceActivityMonitor {
//    
//    let store = ManagedSettingsStore()
//    let database = CKContainer(identifier: "iCloud.com.laborato.Parent").publicCloudDatabase // ⚠️ ВСТАВЬ СВОЙ ID КОНТЕЙНЕРА
//    let appGroup = "group.com.laborato.test.Parent" // ⚠️ ВСТАВЬ СВОЮ ГРУППУ
//    
//    // Этот метод вызывается, когда начинается расписание мониторинга
//    // (например, при перезагрузке телефона или старте приложения)
//    override func intervalDidStart(for activity: DeviceActivityName) {
//        super.intervalDidStart(for: activity)
//        print("MONITOR: Интервал начался. Проверяем команды...")
//        
//        checkCloudKitForPendingCommands()
//        
//        if activity.rawValue.starts(with: "focus_schedule_") {
//            handleFocusScheduleStart(activity: activity)
//        }
//    }
//    
//    // MARK: - Interval Did End
//    // Вызывается, когда заканчивается время активности (например, 12:00 для фокусировки)
//    override func intervalDidEnd(for activity: DeviceActivityName) {
//        super.intervalDidEnd(for: activity)
//        print("MONITOR: Интервал закончился: \(activity.rawValue)")
//        
//        // Если закончилось время фокусировки — снимаем ограничения
//        if activity.rawValue.starts(with: "focus_schedule_") {
//            print("🔓 Время фокусировки истекло. Снимаем блокировку.")
//            store.shield.applicationCategories = nil
//            store.shield.webDomains = nil
//        }
//    }
//    
//    // Этот метод вызывается периодически системой (не гарантировано по времени, но происходит)
//    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
//        super.eventDidReachThreshold(event, activity: activity)
//        // Тоже можно проверить команды
//        checkCloudKitForPendingCommands()
//    }
//    
//    // ==========================================
//    // ЛОГИКА 1: CLOUD KIT COMMANDS (Твой код)
//    // ==========================================
//    
//    private func checkCloudKitForPendingCommands() {
//        // 1. Получаем ID ребенка из общей памяти
//        guard let defaults = UserDefaults(suiteName: appGroup),
//              let childID = defaults.string(forKey: "myChildRecordID") else {
//            print("MONITOR: Child ID не найден в UserDefaults")
//            return
//        }
//        
//        // 2. Ищем команды со статусом "pending"
//        let predicate = NSPredicate(format: "targetChildID == %@ AND status == %@", childID, "pending")
//        let query = CKQuery(recordType: "Command", predicate: predicate)
//        
//        // Сортируем, берем последнюю
//        query.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
//        
//        let operation = CKQueryOperation(query: query)
//        operation.resultsLimit = 1
//        
//        operation.recordMatchedBlock = { recordID, result in
//            switch result {
//            case .success(let record):
//                self.handleRecord(record)
//            case .failure(let error):
//                print("MONITOR: Ошибка получения записи: \(error)")
//            }
//        }
//        
//        database.add(operation)
//    }
//    
//    private func handleRecord(_ record: CKRecord) {
//        guard let commandName = record["commandName"] as? String else { return }
//        print("MONITOR: Найдена команда \(commandName)")
//        
//        // 3. Выполняем блокировку (ManagedSettings работает в расширении!)
//        // Важно: ManagedSettingsStore применяет настройки к устройству, даже если само приложение мертво.
//        if commandName == "block_all" {
//            store.shield.applicationCategories = .all()
//            // store.shield.webDomains = .all()
//        } else if commandName == "unblock_all" {
//            store.shield.applicationCategories = nil
//            store.shield.webDomains = nil
//        }
//        
//        // 4. Обновляем статус в CloudKit
//        record["status"] = "executed"
//        
//        let modifyOp = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
//        modifyOp.savePolicy = .changedKeys
//        modifyOp.modifyRecordsResultBlock = { result in
//             print("MONITOR: Статус обновлен на executed")
//        }
//        
//        database.add(modifyOp)
//    }
//    
//    // ==========================================
//    // ЛОГИКА 2: FOCUS SCHEDULES (Новая логика)
//    // ==========================================
//    
//    private func handleFocusScheduleStart(activity: DeviceActivityName) {
//        // 1. Загружаем
//        guard let defaults = UserDefaults(suiteName: appGroup),
//              let data = defaults.data(forKey: "cached_focus_schedules"),
//              let schedules = try? JSONDecoder().decode([CachedFocusSchedule].self, from: data) else {
//            return
//        }
//        
//        // 2. Ищем расписание
//        let uuidString = activity.rawValue.replacingOccurrences(of: "focus_schedule_", with: "")
//        guard let schedule = schedules.first(where: { $0.id.uuidString == uuidString }) else { return }
//        
//        // 3. Проверяем день недели (ТЕПЕРЬ НАМНОГО ПРОЩЕ И НАДЕЖНЕЕ)
//        if isTodayAllowed(days: schedule.daysOfWeek) {
//            print("🛡 MONITOR: Блокировка включена (День совпал).")
//            store.shield.applicationCategories = .all()
//        } else {
//            print("ℹ️ MONITOR: Сегодня день не по расписанию.")
//        }
//    }
//    
//    // Проверка дня недели
//    private func isTodayAllowed(days: [CachedFocusSchedule.CachedWeekday]) -> Bool {
//        // Получаем текущий день недели (1 = Воскресенье, 2 = Понедельник...)
//        let currentWeekdayInt = Calendar.current.component(.weekday, from: Date())
//        
//        // Проверяем, содержит ли массив этот день
//        // Мы сравниваем rawValue (Int), так надежнее
//        return days.contains { $0.rawValue == currentWeekdayInt }
//    }
//}

import DeviceActivity
import ManagedSettings
import Foundation

class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    
    let appGroup = "group.com.laborato.test.Parent" // Твоя группа
    let store = ManagedSettingsStore()
    
    // Вызывается ТОЛЬКО для расписаний (например, начало урока в 9:00)
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        print("⏰ MONITOR: Интервал начался: \(activity.rawValue)")
        
        guard activity.rawValue.starts(with: "focus_schedule_") else { return }
        
        // 1. Читаем настройки из UserDefaults (которые сохранил Main App)
        guard let defaults = UserDefaults(suiteName: appGroup),
              let data = defaults.data(forKey: "cached_focus_schedules"),
              let schedules = try? JSONDecoder().decode([CachedFocusSchedule].self, from: data) else {
            return
        }
        
        let uuidString = activity.rawValue.replacingOccurrences(of: "focus_schedule_", with: "")
        
        // 2. Ищем нужное расписание и проверяем день недели
        if let schedule = schedules.first(where: { $0.id.uuidString == uuidString }),
           isTodayAllowed(days: schedule.daysOfWeek) {
            
            print("🛡 MONITOR: Включаем блокировку по расписанию")
            // Здесь применяем блокировку
            // store.shield.applicationCategories = ...
            // Логику блокировки берешь из schedule
            store.shield.applicationCategories = .all() // Пример
        }
    }
    
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        
        if activity.rawValue.starts(with: "focus_schedule_") {
            print("🔓 MONITOR: Расписание закончилось")
            // Очищаем блокировки, связанные с расписанием
            store.shield.applicationCategories = nil
            store.shield.webDomains = nil
        }
    }
    
    // Хелпер дня недели
    private func isTodayAllowed(days: [CachedFocusSchedule.CachedWeekday]) -> Bool {
        let currentWeekdayInt = Calendar.current.component(.weekday, from: Date())
        return days.contains { $0.rawValue == currentWeekdayInt }
    }
}
