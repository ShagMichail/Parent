//
//  AppUsageReport.swift
//  Parent
//
//  Created by Михаил Шаговитов on 08.12.2025.
//

import DeviceActivity
import SwiftUI
import ManagedSettings
import Charts

extension DeviceActivityReport.Context {
    static let topAppsCard = Self("App Top Usage")
}

struct TopAppsCardReport: DeviceActivityReportScene {
    // Используем наш новый контекст
    let context: DeviceActivityReport.Context = .topAppsCard
    
    // Контент — это View, который мы вернем
    let content: ([AppReportModel]) -> TopAppsCardView

    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> [AppReportModel] {
        var allApps: [AppReportModel] = []
        
        for await deviceActivity in data {
            for await activitySegment in deviceActivity.activitySegments {
                for await category in activitySegment.categories {
                    for await app in category.applications {
                        let appName = app.application.localizedDisplayName ?? "Unknown"
                        let duration = app.totalActivityDuration
                        // Мы сохраняем токен, чтобы отобразить родную иконку
                        let token = app.application.token
                        
                        allApps.append(AppReportModel(
                            id: app.application.bundleIdentifier ?? UUID().uuidString,
                            name: appName,
                            duration: duration,
                            token: token
                        ))
                    }
                }
            }
        }
        
        // Группируем по ID (на случай дублей) и суммируем время
        let grouped = Dictionary(grouping: allApps, by: { $0.id })
            .map { (key, values) -> AppReportModel in
                let total = values.reduce(0) { $0 + $1.duration }
                let first = values.first!
                return AppReportModel(id: key, name: first.name, duration: total, token: first.token)
            }
        
        // Сортируем и берем топ-2
        return Array(grouped.sorted { $0.duration > $1.duration }.prefix(2))
    }
}
