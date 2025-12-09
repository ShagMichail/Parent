//
//  FocusSchedule.swift
//  Parent
//
//  Created by Михаил Шаговитов on 08.12.2025.
//

import Foundation

struct FocusSchedule: Identifiable, Codable {
    var id = UUID()
    var startTime: Date
    var endTime: Date
    var daysOfWeek: [Weekday]
    var isEnabled: Bool
    
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
