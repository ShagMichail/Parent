//
//  FocusSchedule.swift
//  Parent
//
//  Created by Михаил Шаговитов on 08.12.2025.
//

import Foundation
import CloudKit

struct FocusSchedule: Identifiable, Codable {
    var id = UUID()
    var startTime: Date
    var endTime: Date
    var daysOfWeek: [Weekday]
    var isEnabled: Bool
    var recordID: String?
    
    enum Weekday: Int, Codable, CaseIterable, Identifiable {
        case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday
        
        var id: Int { self.rawValue }
        var shortName: String {
            switch self {
            case .monday: return "ПН"
            case .tuesday: return "ВТ"
            case .wednesday: return "СР"
            case .thursday: return "ЧТ"
            case .friday: return "ПТ"
            case .saturday: return "СБ"
            case .sunday: return "ВС"
            }
        }
        
        var fullName: String {
            switch self {
            case .monday: return "Понедельник"
            case .tuesday: return "Вторник"
            case .wednesday: return "Среда"
            case .thursday: return "Четверг"
            case .friday: return "Пятница"
            case .saturday: return "Суббота"
            case .sunday: return "Воскресенье"
            }
        }
    }
    
    // Форматирование для отображения
    var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return "\(formatter.string(from: startTime)) - \(formatter.string(from: endTime))"
    }
    
    var daysString: String {
        if daysOfWeek.isEmpty { return "Никогда" }
        if daysOfWeek.count == 7 { return "Каждый день" }
        
        // Проверяем, если выбраны только рабочие дни (пн-пт)
        let weekdays: Set<Weekday> = [.monday, .tuesday, .wednesday, .thursday, .friday]
        let selectedSet = Set(daysOfWeek)
        if selectedSet == weekdays && daysOfWeek.count == 5 {
            return "ПН–ПТ"
        }
        
        // Сортируем дни по порядку недели
        let sortedDays = daysOfWeek.sorted { $0.rawValue < $1.rawValue }
        return sortedDays.map { $0.shortName }.joined(separator: ", ")
    }
    
    // Проверяем, активно ли расписание сейчас
    func isActiveNow() -> Bool {
        guard isEnabled else { return false }
        
        let calendar = Calendar.current
        let now = Date()
        let currentWeekday = Weekday(rawValue: calendar.component(.weekday, from: now))
        let currentTime = calendar.dateComponents([.hour, .minute], from: now)
        
        // Проверяем день недели
        guard let weekday = currentWeekday, daysOfWeek.contains(weekday) else {
            return false
        }
        
        // Проверяем время
        let startComponents = calendar.dateComponents([.hour, .minute], from: startTime)
        let endComponents = calendar.dateComponents([.hour, .minute], from: endTime)
        
        guard let startHour = startComponents.hour, let startMinute = startComponents.minute,
              let endHour = endComponents.hour, let endMinute = endComponents.minute,
              let currentHour = currentTime.hour, let currentMinute = currentTime.minute else {
            return false
        }
        
        let currentTotalMinutes = currentHour * 60 + currentMinute
        let startTotalMinutes = startHour * 60 + startMinute
        let endTotalMinutes = endHour * 60 + endMinute
        
        return currentTotalMinutes >= startTotalMinutes && currentTotalMinutes <= endTotalMinutes
    }
}

// Расширение для работы с CloudKit
extension FocusSchedule {
    
    // Преобразование: CKRecord -> FocusSchedule
    init?(record: CKRecord) {
        guard let start = record["startTime"] as? Date,
              let end = record["endTime"] as? Date,
              let enabled = record["isEnabled"] as? Int else { return nil }
        
        self.id = UUID(uuidString: record.recordID.recordName) ?? UUID()
        self.startTime = start
        self.endTime = end
        self.isEnabled = enabled == 1
        
        // Декодируем массив чисел [1, 2, 3] обратно в [Weekday]
        if let rawDays = record["daysOfWeek"] as? [Int] {
            self.daysOfWeek = rawDays.compactMap { Weekday(rawValue: $0) }
        } else {
            self.daysOfWeek = []
        }
        
        // Если нужно сохранить ID записи для обновления/удаления (рекомендуется добавить это свойство в struct)
         self.recordID = record.recordID.recordName
    }
    
    // Преобразование: FocusSchedule -> CKRecord
//    func toRecord(childID: String) -> CKRecord {
//        // Используем UUID как ID записи
//        let recordID = CKRecord.ID(recordName: self.id.uuidString)
//        let record = CKRecord(recordType: "FocusSchedule", recordID: recordID)
//        
//        record["startTime"] = self.startTime as CKRecordValue
//        record["endTime"] = self.endTime as CKRecordValue
//        
//        // Сохраняем дни как массив чисел [Int]
//        let rawDays = self.daysOfWeek.map { $0.rawValue }
//        record["daysOfWeek"] = rawDays as CKRecordValue
//        
//        record["isEnabled"] = (self.isEnabled ? 1 : 0) as CKRecordValue
//        record["targetChildID"] = childID as CKRecordValue
//        
//        return record
//    }
    
    func toRecord(childID: String) -> CKRecord {
        let recordID = CKRecord.ID(recordName: self.id.uuidString)
        let record = CKRecord(recordType: "FocusSchedule", recordID: recordID)
        
        // Основные данные
        record["startTime"] = self.startTime as CKRecordValue
        record["endTime"] = self.endTime as CKRecordValue
        record["isEnabled"] = (self.isEnabled ? 1 : 0) as CKRecordValue
        record["targetChildID"] = childID as CKRecordValue
        
        // Конвертируем время в строки для push-уведомлений
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        record["startTimeString"] = formatter.string(from: self.startTime) as CKRecordValue
        record["endTimeString"] = formatter.string(from: self.endTime) as CKRecordValue
        let rawDays = self.daysOfWeek.map { $0.rawValue }
        record["daysOfWeek"] = rawDays as CKRecordValue
        // --- ✅ НОВЫЙ КОД ДЛЯ ДНЕЙ НЕДЕЛИ ---
        // 1. Преобразуем [Weekday] в [Int]: [monday, friday] -> [2, 6]
//        let rawDaysString = self.daysOfWeek.map { $0.rawValue }
        // 2. Преобразуем [Int] в [String]: [2, 6] -> ["2", "6"]
        let stringDays = rawDays.map { String($0) }
        // 3. Объединяем в одну строку: ["2", "6"] -> "2,6"
        let daysString = stringDays.joined(separator: ",")
        
        record["daysOfWeekString"] = daysString as CKRecordValue
        
        // Старое поле можно закомментировать или удалить
        // record["daysOfWeek"] = rawDays as CKRecordValue
        
        return record
    }
}
