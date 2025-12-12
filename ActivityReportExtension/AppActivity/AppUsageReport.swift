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
        
        var hourlyData = (0..<24).map { HourlyActivityModel(hour: $0, duration: 0) }
        var dailyDataDict: [String: TimeInterval] = [:]
        var appsDict: [ApplicationToken: TimeInterval] = [:]
        
        var todayTotal: TimeInterval = 0
        var yesterdayTotal: TimeInterval = 0
        
        let calendar = Calendar.current
        let now = Date()
        let yesterdayStart = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: now))!
        
        var hasDataOlderThanYesterday = false
        
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
                // Приложения суммируем только если это "Неделя", или если "День" (только за сегодня)
                // Но чтобы упростить, суммируем всё, а фильтруем в уме.
                // Для точности в режиме "День" лучше показывать приложения только за сегодня:
                let isToday = calendar.isDateInToday(start)
                if hasDataOlderThanYesterday || isToday {
                     for await category in segment.categories {
                        for await app in category.applications {
                            let token = app.application.token
                            if let token = token, app.totalActivityDuration > 0 {
                                appsDict[token, default: 0] += app.totalActivityDuration
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
        
        let sortedApps = appsDict.map { AppUsageItem(token: $0.key, duration: $0.value) }
            .sorted { $0.duration > $1.duration }
        
        return ActivityReportViewModel(
            hourlyData: hourlyData,
            dailyData: dailyData,
            apps: sortedApps,
            totalDuration: hasDataOlderThanYesterday ? (todayTotal + yesterdayTotal) : todayTotal,
            yesterdayTotalDuration: yesterdayTotal
        )
    }
}
