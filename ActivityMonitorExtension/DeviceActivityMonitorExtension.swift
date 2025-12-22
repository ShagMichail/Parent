//
//  DeviceActivityMonitorExtension.swift
//  ActivityMonitorExtension
//
//  Created by Михаил Шаговитов on 03.12.2025.
//

import DeviceActivity
import ManagedSettings
import Foundation

//class DeviceActivityMonitorExtension: DeviceActivityMonitor {
//    
//    let appGroup = "group.com.laborato.test.Parent"
//    let store = ManagedSettingsStore()
//    
//    // Вызывается ТОЛЬКО для расписаний (например, начало урока в 9:00)
//    override func intervalDidStart(for activity: DeviceActivityName) {
//        super.intervalDidStart(for: activity)
//        print("⏰ MONITOR: Интервал начался: \(activity.rawValue)")
//        
//        guard activity.rawValue.starts(with: "focus_schedule_") else { return }
//        
//        guard let defaults = UserDefaults(suiteName: appGroup),
//              let data = defaults.data(forKey: "cached_focus_schedules"),
//              let schedules = try? JSONDecoder().decode([CachedFocusSchedule].self, from: data) else {
//            return
//        }
//        
//        let uuidString = activity.rawValue.replacingOccurrences(of: "focus_schedule_", with: "")
//        
//        if let schedule = schedules.first(where: { $0.id.uuidString == uuidString }),
//           isTodayAllowed(days: schedule.daysOfWeek) {
//            
//            print("🛡 MONITOR: Включаем блокировку по расписанию")
//            store.shield.applicationCategories = .all()
//        }
//    }
//    
//    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
//        super.eventDidReachThreshold(event, activity: activity)
//        
//        if activity.rawValue.starts(with: "limit.") {
//            print("⏳ Лимит времени для приложения исчерпан!")
//            
//            let center = DeviceActivityCenter()
//            let events = center.events(for: activity)
//            if let appEvent = events[event] {
//                store.shield.applications = appEvent.applications
//            }
//        }
//    }
//    
//    override func intervalDidEnd(for activity: DeviceActivityName) {
//        super.intervalDidEnd(for: activity)
//        
//        if activity.rawValue.starts(with: "focus_schedule_") {
//            print("🔓 MONITOR: Расписание закончилось")
//            store.shield.applicationCategories = nil
//            store.shield.webDomains = nil
//        }
//        
//        if activity.rawValue.starts(with: "limit.") {
//            print("✅ Лимит сброшен (наступил новый день).")
//            // Просто убираем все блокировки, чтобы они не висели вечно
//            store.shield.applications = nil
//        }
//    }
//    
//    private func isTodayAllowed(days: [CachedFocusSchedule.CachedWeekday]) -> Bool {
//        let currentWeekdayInt = Calendar.current.component(.weekday, from: Date())
//        return days.contains { $0.rawValue == currentWeekdayInt }
//    }
//}

import DeviceActivity
import ManagedSettings
import Foundation

class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    
    let store = ManagedSettingsStore()
    let defaults = UserDefaults(suiteName: "group.com.laborato.test.Parent")

    // ===================================================================
    // ОБРАБОТКА РАСПИСАНИЙ (Focus Schedules) - ВАШ КОД, БЕЗ ИЗМЕНЕНИЙ
    // ===================================================================
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        print("⏰ [MONITOR] Начался интервал для активности: \(activity.rawValue)")
        
        // --- Логика для Расписаний (focus_schedule_) ---
        if activity.rawValue.starts(with: "focus_schedule_") {
            handleFocusScheduleStart(for: activity)
        }
    }
    
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        print("🌙 [MONITOR] Закончился интервал для активности: \(activity.rawValue)")
        
        // --- Логика для Расписаний (focus_schedule_) ---
        if activity.rawValue.starts(with: "focus_schedule_") {
            print("🔓 [MONITOR] Расписание 'Фокус' закончилось. Снимаем блокировку.")
            // ВАЖНО: Мы не можем просто снять все. Нужно проверить, не активны ли лимиты.
            // Пока для простоты снимаем, но в будущем это потребует доработки.
            store.shield.applications = nil
            store.shield.applicationCategories = nil
            store.shield.webDomainCategories = nil
        }
        
        // --- Логика для Лимитов (limit_) ---
        // intervalDidEnd для лимитов означает конец дня (00:00).
        // Блокировка снимается, и на следующий день счетчик начнется заново.
        if activity.rawValue.starts(with: "limit_") {
            print("✅ [MONITOR] Новый день. Сбрасываем блокировку лимита для \(activity.rawValue).")
            // Здесь тоже может быть конфликт с расписаниями, но пока просто снимаем.
            store.shield.applications = nil
        }
    }

    // ===================================================================
    // ✅ ОБРАБОТКА ЛИМИТОВ (App Limits) - НОВАЯ ЛОГИКА
    // ===================================================================
    
    /// Система вызывает этот метод, когда СУММАРНОЕ ВРЕМЯ ИСПОЛЬЗОВАНИЯ превысило порог.
    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
        
        print("⏳ [MONITOR] Порог времени достигнут для события '\(event.rawValue)' в рамках активности '\(activity.rawValue)'")
        
        // Проверяем, что это наша активность с лимитом
        guard activity.rawValue.starts(with: "limit_") else { return }
        
        // 1. Читаем все сохраненные лимиты из UserDefaults
        guard let data = defaults?.data(forKey: "app_limits_cache"),
              let allLimits = try? JSONDecoder().decode([AppLimit].self, from: data) else {
            print("❌ [MONITOR] Не удалось прочитать кэш лимитов в UserDefaults.")
            return
        }
        
        // 2. Находим, какой именно лимит времени сработал
        // Имя активности у нас "limit_3600"
        let timeString = activity.rawValue.replacingOccurrences(of: "limit_", with: "")
        guard let timeLimit = TimeInterval(timeString) else { return }
        
        // 3. Находим все приложения, которые относятся к этому сработавшему лимиту
        let tokensToBlock = allLimits
            .filter { $0.time == timeLimit }
            .map { $0.token }
        
        // 4. БЛОКИРУЕМ ИХ
        if !tokensToBlock.isEmpty {
            print("🛡 [MONITOR] Блокируем \(tokensToBlock.count) приложений для лимита \(Int(timeLimit/60)) мин.")
            
            // ВАЖНО: Мы должны ДОБАВИТЬ новые токены к уже заблокированным,
            // а не перезаписывать их, чтобы не снять блокировку от расписаний.
            var currentlyShielded = store.shield.applications ?? []
            currentlyShielded.formUnion(tokensToBlock)
            store.shield.applications = currentlyShielded
        }
    }
    
    // ===================================================================
    // Вспомогательные функции
    // ===================================================================
    
    /// Обрабатывает начало расписания "Фокус" (ваш существующий код)
    private func handleFocusScheduleStart(for activity: DeviceActivityName) {
        guard let data = defaults?.data(forKey: "cached_focus_schedules"),
              let schedules = try? JSONDecoder().decode([CachedFocusSchedule].self, from: data) else {
            return
        }
        
        let uuidString = activity.rawValue.replacingOccurrences(of: "focus_schedule_", with: "")
        
        if let schedule = schedules.first(where: { $0.id.uuidString == uuidString }),
           isTodayAllowed(days: schedule.daysOfWeek) {
            
            print("🛡 [MONITOR] Включаем блокировку по расписанию 'Фокус'.")
            store.shield.applicationCategories = .all()
            store.shield.webDomainCategories = .all()
        }
    }
    
    /// Проверяет, активен ли сегодня день для расписания (ваш существующий код)
    private func isTodayAllowed(days: [CachedFocusSchedule.CachedWeekday]) -> Bool {
        let currentWeekdayInt = Calendar.current.component(.weekday, from: Date())
        return days.contains { $0.rawValue == currentWeekdayInt }
    }
}

// Убедитесь, что эти структуры доступны для этого таргета
struct AppLimit: Codable, Hashable {
    let token: ApplicationToken
    var time: TimeInterval
}
