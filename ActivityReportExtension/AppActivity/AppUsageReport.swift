//
//  AppUsageReport.swift
//  Parent
//
//  Created by Михаил Шаговитов on 24.11.2025.
//

import DeviceActivity
import SwiftUI
import Charts
import ManagedSettings
import OSLog

extension DeviceActivityReport.Context {
    static let appUsageActivity = Self("App Usage Activity")
}

struct AppUsageReport: DeviceActivityReportScene {
    let context: DeviceActivityReport.Context = .appUsageActivity
    let content: (ActivityReportViewModel) -> AppUsageView
    
    let logger = Logger(subsystem: "com.tracker.reports", category: "DataDebug")
    
    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> ActivityReportViewModel {
        
        var detailedDailyAppsDict: [ApplicationToken: [Date: TimeInterval]] = [:]
        var detailedHourlyAppsDict: [ApplicationToken: [Int: TimeInterval]] = [:]
        var applications: [ApplicationToken: Application] = [:]
        var appCategories: [ApplicationToken: ActivityCategory] = [:]

        
        var hourlyData = (0..<24).map { HourlyActivityModel(hour: $0, duration: 0) }
        var dailyDataDict: [String: TimeInterval] = [:]
        var appsDict: [ApplicationToken: TimeInterval] = [:]
        
        var todayTotal: TimeInterval = 0
        var yesterdayTotal: TimeInterval = 0
        
        let calendar = Calendar.current
        let now = Date()
        let yesterdayStart = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: now))!
        
        var hasDataOlderThanYesterday = false
        var showWeeklyReport = false
        
        for await deviceActivity in data {
            for await segment in deviceActivity.activitySegments {
                let start = segment.dateInterval.start
                let duration = segment.totalActivityDuration
                
                // --- ОПРЕДЕЛЯЕМ РЕЖИМ ---
                if start < yesterdayStart {
                    hasDataOlderThanYesterday = true
                }
                // --- СБОР ОБЩИХ СУММ ---
                if calendar.isDateInToday(start) {
                    todayTotal += duration
                } else if calendar.isDateInYesterday(start) {
                    yesterdayTotal += duration
                } else {
                    // Если есть данные старше чем за вчера, мы точно в режиме "Неделя"
                    showWeeklyReport = true
                }
                
                // --- 1. ДАННЫЕ ДЛЯ ГРАФИКА ДНЯ (Заполняем только данными за СЕГОДНЯ) ---
                if calendar.isDateInToday(start) {
                    var currentPointer = start
                    let end = segment.dateInterval.end
                    while currentPointer < end {
                        let hour = calendar.component(.hour, from: currentPointer)
                        
                        // Находим конец текущего часа
                        if let nextHour = calendar.date(byAdding: .hour, value: 1, to: calendar.date(bySetting: .minute, value: 0, of: currentPointer)!) {
                            
                            let delta = min(nextHour.timeIntervalSince(currentPointer), end.timeIntervalSince(currentPointer))
                            
                            let segmentDuration = segment.totalActivityDuration
                            if hour >= 0 && hour < 24 {
                                hourlyData[hour] = HourlyActivityModel(hour: hour, duration: hourlyData[hour].duration + segmentDuration)
                            }
                            currentPointer += delta
                        } else { break }
                    }
                }
                
                // --- 2. ДАННЫЕ ДЛЯ ГРАФИКА НЕДЕЛИ ---
                // Собираем всё подряд по дням
                let dayStart = calendar.startOfDay(for: start)
                let dateKey = String(dayStart.timeIntervalSince1970)
                dailyDataDict[dateKey, default: 0] += duration
                
                // --- 3. ПРИЛОЖЕНИЯ ---
                for await category in segment.categories {
                    for await app in category.applications {
                        if let token = app.application.token, app.totalActivityDuration > 0 {
                            // Сохраняем метаданные
                            if applications[token] == nil { applications[token] = app.application }
                            if appCategories[token] == nil { appCategories[token] = category.category }
                            
                            // Собираем дневную статистику
                            detailedDailyAppsDict[token, default: [:]][dayStart, default: 0] += app.totalActivityDuration
                            
                            // Собираем почасовую статистику (только за сегодня)
                            if calendar.isDateInToday(start) {
                                let hour = calendar.component(.hour, from: start)
                                detailedHourlyAppsDict[token, default: [:]][hour, default: 0] += app.totalActivityDuration
                            }
                        }
                    }
                }
            }
        }
        
        // ФОРМИРУЕМ МАССИВ ДНЕЙ
        var dailyData: [DailyActivityModel] = []
        if hasDataOlderThanYesterday {
            for i in 0..<7 {
                if let date = calendar.date(byAdding: .day, value: -i, to: now) {
                    let startOfDay = calendar.startOfDay(for: date)
                    let key = String(startOfDay.timeIntervalSince1970)
                    dailyData.insert(DailyActivityModel(date: startOfDay, duration: dailyDataDict[key] ?? 0), at: 0)
                }
            }
        }

        let sortedAppDetails = detailedDailyAppsDict.map { token, dailyData -> AppUsageDetail in
            var totalDuration = dailyData.reduce(0) { $0 + $1.value }
            
            if !showWeeklyReport {
                let todayStart = calendar.startOfDay(for: now)
                totalDuration = dailyData[todayStart] ?? 0
            } else {
                // Если в режиме "Неделя", суммируем за все дни
                totalDuration = dailyData.reduce(0) { $0 + $1.value }
            }
            
            // Преобразуем почасовой словарь в массив
            let hourlyDict = detailedHourlyAppsDict[token] ?? [:]
            var hourlyArray = Array(repeating: 0.0, count: 24)
            for (hour, duration) in hourlyDict {
                if hour >= 0 && hour < 24 {
                    hourlyArray[hour] = duration
                }
            }
            
            return AppUsageDetail(
                token: token,
                totalDuration: totalDuration,
                dailyUsage: dailyData,
                hourlyUsage: hourlyArray,
                application: applications[token]!,
                category: appCategories[token]!
            )
        }
            .filter { $0.totalDuration > 0 }
            .sorted { $0.totalDuration > $1.totalDuration }
        
        return ActivityReportViewModel(
            hourlyData: hourlyData,
            dailyData: dailyData,
            apps: sortedAppDetails,
            totalDuration: hasDataOlderThanYesterday ? (todayTotal + yesterdayTotal) : todayTotal,
            yesterdayTotalDuration: yesterdayTotal,
            isWeekView: showWeeklyReport
        )
    }
}
