//
//  ActivityReportViewModel.swift
//  Parent
//
//  Created by Michail Shagovitov on 12.12.2025.
//

import Foundation
import ManagedSettings

struct DailyActivityModel: Identifiable {
    var id: String { dateString }
    let date: Date
    let duration: TimeInterval
    
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM"
        return formatter.string(from: date)
    }
    
    var weekday: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "EE"
        return formatter.string(from: date)
    }
}

struct ActivityReportViewModel: Equatable {
    let hourlyData: [HourlyActivityModel]
    let dailyData: [DailyActivityModel]
    let apps: [AppUsageDetail]
    let totalDuration: TimeInterval
    let yesterdayTotalDuration: TimeInterval
    var isWeekView: Bool
    
    static func == (lhs: ActivityReportViewModel, rhs: ActivityReportViewModel) -> Bool {
        return lhs.isWeekView == rhs.isWeekView
    }
}

struct AppUsageDetail: Identifiable, Hashable {
    let id = UUID()
    let token: ApplicationToken
    let totalDuration: TimeInterval
    let totalNotifications: Int
    let dailyUsage: [Date: TimeInterval]
    let hourlyUsage: [TimeInterval]
    let application: Application
    let category: ActivityCategory
}

enum ChartDetailType {
    case daily, hourly
}
