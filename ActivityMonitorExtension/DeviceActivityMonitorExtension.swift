//
//  DeviceActivityMonitorExtension.swift
//  ActivityMonitorExtension
//
//  Created by Михаил Шаговитов on 03.12.2025.
//

import DeviceActivity
import ManagedSettings
import Foundation

class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    
    let appGroup = "group.com.laborato.test.Parent"
    let store = ManagedSettingsStore()
    
    // Вызывается ТОЛЬКО для расписаний (например, начало урока в 9:00)
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        print("⏰ MONITOR: Интервал начался: \(activity.rawValue)")
        
        guard activity.rawValue.starts(with: "focus_schedule_") else { return }
        
        guard let defaults = UserDefaults(suiteName: appGroup),
              let data = defaults.data(forKey: "cached_focus_schedules"),
              let schedules = try? JSONDecoder().decode([CachedFocusSchedule].self, from: data) else {
            return
        }
        
        let uuidString = activity.rawValue.replacingOccurrences(of: "focus_schedule_", with: "")
        
        if let schedule = schedules.first(where: { $0.id.uuidString == uuidString }),
           isTodayAllowed(days: schedule.daysOfWeek) {
            
            print("🛡 MONITOR: Включаем блокировку по расписанию")
            store.shield.applicationCategories = .all()
        }
    }
    
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        
        if activity.rawValue.starts(with: "focus_schedule_") {
            print("🔓 MONITOR: Расписание закончилось")
            store.shield.applicationCategories = nil
            store.shield.webDomains = nil
        }
    }
    
    private func isTodayAllowed(days: [CachedFocusSchedule.CachedWeekday]) -> Bool {
        let currentWeekdayInt = Calendar.current.component(.weekday, from: Date())
        return days.contains { $0.rawValue == currentWeekdayInt }
    }
}
