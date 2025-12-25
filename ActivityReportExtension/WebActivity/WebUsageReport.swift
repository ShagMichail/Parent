//
//  WebUsageReport.swift
//  Parent
//
//  Created by Michail Shagovitov on 23.12.2025.
//

// WebUsageReport.swift
import DeviceActivity
import SwiftUI
import ManagedSettings

extension DeviceActivityReport.Context {
    static let webUsageActivity = Self("Web Usage Activity")
}

struct WebUsageReport: DeviceActivityReportScene {
    let context: DeviceActivityReport.Context = .webUsageActivity
    let content: (WebReportViewModel) -> WebUsageView
    
    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> WebReportViewModel {
        
        var detailedDailyWebDict: [WebDomainToken: [Date: TimeInterval]] = [:]
        var detailedHourlyWebDict: [WebDomainToken: [Int: TimeInterval]] = [:]
        var webDomains: [WebDomainToken: String] = [:]
        
        var hourlyData = (0..<24).map { HourlyActivityModel(hour: $0, duration: 0) }
        var dailyDataDict: [Date: TimeInterval] = [:]
        
        var todayTotal: TimeInterval = 0
        var yesterdayTotal: TimeInterval = 0
        
        let calendar = Calendar.current
        let now = Date()
        var showWeeklyReport = false
        
        for await deviceActivity in data {
            for await segment in deviceActivity.activitySegments {
                let start = segment.dateInterval.start
                let dayStart = calendar.startOfDay(for: start)
                
                // --- СБОР ОБЩИХ СУММ ---
                if calendar.isDateInToday(start) {
                } else if calendar.isDateInYesterday(start) {
                } else {
                    showWeeklyReport = true
                }
                
                // --- Сбор данных ТОЛЬКО по веб-сайтам ---
                var segmentWebDuration: TimeInterval = 0
                for await categoryActivity in segment.categories {
                    for await webDomainActivity in categoryActivity.webDomains {
                        guard let token = webDomainActivity.webDomain.token, webDomainActivity.totalActivityDuration > 0 else { continue }
                        
                        let duration = webDomainActivity.totalActivityDuration
                        segmentWebDuration += duration
                        
                        if webDomains[token] == nil { webDomains[token] = webDomainActivity.webDomain.domain }
                        detailedDailyWebDict[token, default: [:]][dayStart, default: 0] += duration
                        if calendar.isDateInToday(start) {
                            let hour = calendar.component(.hour, from: start)
                            detailedHourlyWebDict[token, default: [:]][hour, default: 0] += duration
                        }
                    }
                }
                
                // --- Наполняем общие графики, используя ТОЛЬКО `segmentWebDuration` ---
                dailyDataDict[dayStart, default: 0] += segmentWebDuration
                if calendar.isDateInToday(start) {
                    todayTotal += segmentWebDuration
                    let hour = calendar.component(.hour, from: start)
                    if hour >= 0 && hour < 24 {
                        hourlyData[hour].duration += segmentWebDuration
                    }
                } else if calendar.isDateInYesterday(start) {
                    yesterdayTotal += segmentWebDuration
                }
            }
        }
        
        // --- ФОРМИРУЕМ ВЫХОДНЫЕ ДАННЫЕ (логика взята из AppUsageReport) ---
        var dailyData: [DailyActivityModel] = []
        // Показываем 7 дней, только если выбран режим "Неделя"
        if showWeeklyReport {
            for i in 0..<7 {
                if let date = calendar.date(byAdding: .day, value: -i, to: now) {
                    let startOfDay = calendar.startOfDay(for: date)
                    dailyData.insert(DailyActivityModel(date: startOfDay, duration: dailyDataDict[startOfDay] ?? 0), at: 0)
                }
            }
        }
        
        let sortedWebDetails: [WebUsageDetail] = detailedDailyWebDict.compactMap { token, dailyUsage in
            var totalDuration = dailyUsage.reduce(0) { $0 + $1.value }
            
            if !showWeeklyReport {
                let todayStart = calendar.startOfDay(for: now)
                totalDuration = dailyUsage[todayStart] ?? 0
            } else {
                // Если в режиме "Неделя", суммируем за все дни
                totalDuration = dailyUsage.reduce(0) { $0 + $1.value }
            }
            
            guard totalDuration > 0, let displayName = webDomains[token] else { return nil }
                        
            let hourlyDict = detailedHourlyWebDict[token] ?? [:]
            var hourlyArray = Array(repeating: 0.0, count: 24)
            for (hour, duration) in hourlyDict {
                if hour >= 0 && hour < 24 {
                    hourlyArray[hour] = duration
                }
            }
            
            return WebUsageDetail(
                token: token,
                totalDuration: totalDuration,
                displayName: displayName,
                dailyUsage: dailyUsage,
                hourlyUsage: hourlyArray
            )
        }.sorted { $0.totalDuration > $1.totalDuration }
        
        return WebReportViewModel(
            hourlyData: hourlyData,
            dailyData: dailyData,
            websites: sortedWebDetails,
            totalDuration: todayTotal,
            yesterdayTotalDuration: yesterdayTotal,
            isWeekView: showWeeklyReport
        )
    }
}
