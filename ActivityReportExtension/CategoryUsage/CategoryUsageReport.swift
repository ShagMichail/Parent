//
//  CategoryUsageReport.swift
//  Parent
//
//  Created by Michail Shagovitov on 23.12.2025.
//

import DeviceActivity
import SwiftUI
import ManagedSettings

extension DeviceActivityReport.Context {
    static let categoryUsageActivity = Self("Category Usage Activity")
}

struct CategoryUsageReport: DeviceActivityReportScene {
    let context: DeviceActivityReport.Context = .categoryUsageActivity
    let content: (CategoryReportViewModel) -> CategoryUsageView

    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> CategoryReportViewModel {
        let defaults = UserDefaults(suiteName: "group.com.laborato.test.Parent")
        let childAppleID = defaults?.string(forKey: "myChildAppleID")
        
        // --- Словари для сбора сырых данных ---
        var timeByCategory: [ActivityCategory: [Date: TimeInterval]] = [:]
        var timeByApp: [ApplicationToken: [Date: TimeInterval]] = [:]
        var notificationsByApp: [ApplicationToken: Int] = [:]
        
        // Словарь для почасовой статистики КАЖДОГО приложения
        var hourlyUsageByApp: [ApplicationToken: [Int: TimeInterval]] = [:]
        
        // Метаданные
        var applications: [ApplicationToken: Application] = [:]
        var appToCategoryMap: [ApplicationToken: ActivityCategory] = [:]
        
        // Общая статистика
        var dailyTotalDuration: [Date: TimeInterval] = [:]
        
        // Массив для ОБЩЕГО почасового графика
        var totalHourlyData = (0..<24).map { HourlyActivityModel(hour: $0, duration: 0) }
        
        let calendar = Calendar.current
        let now = Date()
        let todayStart = calendar.startOfDay(for: now)
        let yesterdayStart = calendar.date(byAdding: .day, value: -1, to: todayStart)!
        var isWeekView = false
        
        // --- Главный цикл сбора данных ---
        for await deviceActivity in data {
            if deviceActivity.user.appleID == childAppleID {
                for await segment in deviceActivity.activitySegments {
                    let start = segment.dateInterval.start
                    let dayStart = calendar.startOfDay(for: start)
                    
                    // --- СБОР ОБЩИХ СУММ ---
                    if calendar.isDateInToday(start) {
                    } else if calendar.isDateInYesterday(start) {
                    } else {
                        isWeekView = true
                    }
                    
                    dailyTotalDuration[dayStart, default: 0] += segment.totalActivityDuration
                    
                    // Собираем данные для ОБЩЕГО почасового графика
                    if calendar.isDateInToday(start) {
                        let hour = calendar.component(.hour, from: start)
                        if hour >= 0 && hour < 24 {
                            totalHourlyData[hour].duration += segment.totalActivityDuration
                        }
                    }
                    
                    for await categoryActivity in segment.categories {
                        timeByCategory[categoryActivity.category, default: [:]][dayStart, default: 0] += categoryActivity.totalActivityDuration
                        
                        for await appActivity in categoryActivity.applications {
                            guard let token = appActivity.application.token else { continue }
                            
                            if applications[token] == nil { applications[token] = appActivity.application }
                            if appToCategoryMap[token] == nil { appToCategoryMap[token] = categoryActivity.category }
                            
                            timeByApp[token, default: [:]][dayStart, default: 0] += appActivity.totalActivityDuration
                            notificationsByApp[token, default: 0] += appActivity.numberOfNotifications
                            
                            // Собираем почасовые данные для КАЖДОГО приложения
                            if calendar.isDateInToday(start) {
                                let hour = calendar.component(.hour, from: start)
                                hourlyUsageByApp[token, default: [:]][hour, default: 0] += appActivity.totalActivityDuration
                            }
                        }
                    }
                }
            }
        }
        
        // --- Обработка и трансформация данных ---
        
        // --- 1. Собираем детальную информацию по приложениям ---
        var allAppDetails: [AppUsageDetail] = []
        for (token, dailyUsage) in timeByApp {
            guard let application = applications[token], let category = appToCategoryMap[token] else { continue }
            let totalDuration = isWeekView ? dailyUsage.values.reduce(0, +) : (dailyUsage[todayStart] ?? 0)
            guard totalDuration > 0 else { continue }
            
            // Преобразуем почасовой словарь в массив
            let hourlyUsage = (0..<24).map { hourlyUsageByApp[token]?[$0] ?? 0 }

            allAppDetails.append(AppUsageDetail(
                token: token,
                totalDuration: totalDuration,
                totalNotifications: notificationsByApp[token] ?? 0,
                dailyUsage: dailyUsage,
                hourlyUsage: hourlyUsage,
                application: application,
                category: category
            ))
        }
        
        let appsGroupedByName = Dictionary(grouping: allAppDetails) {
            $0.category.localizedDisplayName ?? "Неизвестная"
        }
        
        // --- 2. Собираем детальную информацию по категориям, группируя приложения ---
        let sortedCategoryDetails: [CategoryUsageDetail] = appsGroupedByName.compactMap { (categoryName, appsInThisCategory) -> CategoryUsageDetail? in
            
            // Получаем сам объект категории из первого приложения в группе
            guard let category = appsInThisCategory.first?.category else { return nil }
            
            let dailyUsage = timeByCategory[category] ?? [:]
            let totalDuration = isWeekView ? dailyUsage.values.reduce(0, +) : (dailyUsage[todayStart] ?? 0)
            guard totalDuration > 0 else { return nil }
            
            let totalNotifications = appsInThisCategory.reduce(into: 0) { $0 += $1.totalNotifications }
            
            // Эту логику нужно будет дописать, если почасовая разбивка нужна
            let hourlyUsage: [Double] = (0..<24).map { hour in
                // Суммируем почасовые данные для всех приложений в этой категории
                appsInThisCategory.reduce(0) { total, app in
                    // Здесь мы предполагаем, что hourlyUsage в AppUsageDetail уже заполнен
                    let hourUsage = (app.hourlyUsage.count > hour) ? app.hourlyUsage[hour] : 0
                    return total + hourUsage
                }
            }

            return CategoryUsageDetail(
                category: category,
                totalDuration: totalDuration,
                totalNotifications: totalNotifications,
                applications: appsInThisCategory.sorted { $0.totalDuration > $1.totalDuration },
                dailyUsage: dailyUsage,
                hourlyUsage: hourlyUsage
            )
            
        }.sorted { $0.totalDuration > $1.totalDuration }

        // --- 3. Формируем общие данные для графиков ---
        var dailyData: [DailyActivityModel] = []
        for i in 0..<(isWeekView ? 7 : 1) {
            let date = calendar.date(byAdding: .day, value: -i, to: now)!
            let startOfDay = calendar.startOfDay(for: date)
            dailyData.insert(DailyActivityModel(date: startOfDay, duration: dailyTotalDuration[startOfDay] ?? 0), at: 0)
        }
        
        let todayDuration = dailyTotalDuration[todayStart] ?? 0
        let yesterdayDuration = dailyTotalDuration[yesterdayStart] ?? 0
        
        return CategoryReportViewModel(
            hourlyData: totalHourlyData,
            dailyData: dailyData,
            categories: sortedCategoryDetails,
            totalDuration: todayDuration,
            yesterdayTotalDuration: yesterdayDuration,
            isWeekView: isWeekView
        )
    }
}
