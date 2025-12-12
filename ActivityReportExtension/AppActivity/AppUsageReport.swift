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

extension DeviceActivityReport.Context {
    static let appUsageActivity = Self("App Usage Activity")
}

struct AppUsageReport: DeviceActivityReportScene {
    let context: DeviceActivityReport.Context = .appUsageActivity
    let content: (ActivityReportViewModel) -> AppUsageView
    
    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> ActivityReportViewModel {
        
        // 1. Заготовки
        var hourlyData = (0..<24).map { HourlyActivityModel(hour: $0, duration: 0) }
        var dailyDataDict: [String: TimeInterval] = [:] // Словарь "2023-10-10": 3600
        var appsDict: [ApplicationToken: TimeInterval] = [:]
        
        var totalDuration: TimeInterval = 0
        var yesterdayTotal: TimeInterval = 0 // Для сравнения (можно доработать позже)
        
        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: Date())
        
        // Массив всех дат за последнюю неделю для правильной сортировки графика недели
        // Чтобы на графике были даже дни с 0 активностью
        var last7DaysDates: [Date] = []
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -i, to: Date()) {
                last7DaysDates.append(calendar.startOfDay(for: date))
            }
        }
        last7DaysDates = last7DaysDates.reversed() // От прошлого к сегодня
        
        for await deviceActivity in data {
            for await segment in deviceActivity.activitySegments {
                let start = segment.dateInterval.start
                let duration = segment.totalActivityDuration
                
                totalDuration += duration
                
                // --- ЛОГИКА ДЛЯ ГРАФИКА "ДЕНЬ" (Строго только сегодня) ---
                if calendar.isDateInToday(start) {
                    // Разбиваем по часам (наша старая точная логика)
                    var currentPointer = start
                    let end = segment.dateInterval.end
                    
                    while currentPointer < end {
                        let hour = calendar.component(.hour, from: currentPointer)
                        if let nextHour = calendar.date(byAdding: .hour, value: 1, to: calendar.date(bySetting: .minute, value: 0, of: currentPointer)!) {
                            let delta = min(nextHour.timeIntervalSince(currentPointer), end.timeIntervalSince(currentPointer))
                            if hour >= 0 && hour < 24 {
                                hourlyData[hour] = HourlyActivityModel(hour: hour, duration: hourlyData[hour].duration + delta)
                            }
                            currentPointer += delta
                        } else { break }
                    }
                }
                
                // --- ЛОГИКА ДЛЯ ГРАФИКА "НЕДЕЛЯ" ---
                let dayStart = calendar.startOfDay(for: start)
                let dateKey = String(dayStart.timeIntervalSince1970) // Используем Timestamp как ключ
                dailyDataDict[dateKey, default: 0] += duration
                
                // --- ПРИЛОЖЕНИЯ ---
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
        
        // Формируем итоговый массив для недели (заполняем нулями пустые дни)
        let dailyData: [DailyActivityModel] = last7DaysDates.map { date in
            let key = String(date.timeIntervalSince1970)
            return DailyActivityModel(date: date, duration: dailyDataDict[key] ?? 0)
        }
        
        let sortedApps = appsDict.map { AppUsageItem(token: $0.key, duration: $0.value) }
            .sorted { $0.duration > $1.duration }
        
        // Определяем, режим недели это или дня, исходя из данных.
        // Если фильтр в родителе был "Неделя", то dailyDataDict будет содержать старые даты.
        // Если "День", то там будет только сегодня.
        // Но мы передаем оба массива, View сама разберется.
        
        return ActivityReportViewModel(
            hourlyData: hourlyData,
            dailyData: dailyData,
            apps: sortedApps,
            totalDuration: totalDuration,
            yesterdayTotalDuration: 0 // Упростили пока
        )
    }
}
