//
//  CategoryReportViewModel.swift
//  Parent
//
//  Created by Michail Shagovitov on 23.12.2025.
//

// CategoryReportModels.swift
import Foundation
import DeviceActivity
import ManagedSettings


struct CategoryUsageDetail: Identifiable, Equatable, Hashable {
    var id: String { category.localizedDisplayName ?? "unknown" }
    
    let category: ActivityCategory
    let totalDuration: TimeInterval
    let totalNotifications: Int
    
    // Список приложений внутри категории
    let applications: [AppUsageDetail]
    
    // Данные для графиков на детальном экране
    let dailyUsage: [Date: TimeInterval]
    let hourlyUsage: [Double]
    
    // Ручная реализация
    static func == (lhs: CategoryUsageDetail, rhs: CategoryUsageDetail) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}


// --- ViewModel для всего отчета ---
struct CategoryReportViewModel: Equatable {
    let hourlyData: [HourlyActivityModel]
    let dailyData: [DailyActivityModel]
    let categories: [CategoryUsageDetail]
    let totalDuration: TimeInterval
    let yesterdayTotalDuration: TimeInterval
    let isWeekView: Bool
    
    static func == (lhs: CategoryReportViewModel, rhs: CategoryReportViewModel) -> Bool {
        lhs.categories == rhs.categories && lhs.isWeekView == rhs.isWeekView
    }
}

