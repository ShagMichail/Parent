//
//  ActivityReportViewModel.swift
//  Parent
//
//  Created by Michail Shagovitov on 12.12.2025.
//

import Foundation
import ManagedSettings

struct AppUsageItem: Identifiable, Hashable {
    let id = UUID()
    let token: ApplicationToken // Токен для отображения иконки и имени
    let duration: TimeInterval
}

// Структура для одного дня недели
struct DailyActivityModel: Identifiable {
    var id: String { dateString } // Уникальность по дате
    let date: Date
    let duration: TimeInterval
    
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM" // Формат "12.05"
        return formatter.string(from: date)
    }
    
    var weekday: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "EE" // "Пн", "Вт"
        return formatter.string(from: date)
    }
}

struct ActivityReportViewModel {
    let hourlyData: [HourlyActivityModel] // Для режима "День"
    let dailyData: [DailyActivityModel]   // Для режима "Неделя"
    let apps: [AppUsageItem]
    let totalDuration: TimeInterval
    let yesterdayTotalDuration: TimeInterval
    
    // Определяем режим просмотра: если данных больше чем за 1 день, значит это Неделя
    var isWeekView: Bool {
        return !dailyData.isEmpty && dailyData.count > 1
    }
}
