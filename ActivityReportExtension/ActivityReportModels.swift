//
//  ActivityReportModels.swift
//  Parent
//
//  Created by Михаил Шаговитов on 14.11.2025.
//

import Foundation
import DeviceActivity
import ManagedSettings

enum TimePeriod: String, CaseIterable, Identifiable {
    case today = "Сегодня"
    case last7Days = "Неделя"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .today: return "sun.max.fill"
        case .last7Days: return "calendar"
        }
    }
    
    var deviceActivitySegment: DeviceActivityFilter.SegmentInterval {
        let calendar = Calendar.current
        let now = Date()
        
        switch self {
        case .today:
            let startOfDay = calendar.startOfDay(for: now)
            return .hourly(during: DateInterval(start: startOfDay, end: now))
            
        case .last7Days:
            let start = now.addingTimeInterval(-604800)
            return .daily(during: DateInterval(start: start, end: now))
        }
    }
    
    var aggregationDescription: String {
        switch self {
        case .today:
            return "Информация за сегодняшний день"
        case .last7Days:
            return "Информация за последние 7 дней"
        }
    }
}

struct AppUsageData {
    let topFiveApps: [AppUsageInfo]
    let allApps: [AppUsageInfo]
}

struct AppUsageInfo: Identifiable {
    let id = UUID()
    let appName: String
    let bundleIdentifier: String
    let duration: TimeInterval
    let category: String
}

struct AppReportModel: Identifiable {
    let id: String
    let name: String
    let duration: TimeInterval
    let token: ApplicationToken?
}
