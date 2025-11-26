//
//  AppUsageReport.swift
//  Parent
//
//  Created by Михаил Шаговитов on 24.11.2025.
//

import DeviceActivity
import SwiftUI
import ManagedSettings
import Charts

extension DeviceActivityReport.Context {
    static let appUsage = Self("App Usage")
}

struct AppUsageReport: DeviceActivityReportScene, CommonFunctions {
    
    let context: DeviceActivityReport.Context = .appUsage
    let content: (CombinedActivityData) -> AppUsageChartView

    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> CombinedActivityData {
        // Получаем данные об использовании приложений
        var appUsageData: [AppUsageInfo] = []
        
        for await deviceActivity in data {
            for await activitySegment in deviceActivity.activitySegments {
                for await categoryActivity in activitySegment.categories {
                    for await applicationActivity in categoryActivity.applications {
                        let application = applicationActivity.application
                        let appName = application.localizedDisplayName ?? "Unknown App"
                        let bundleIdentifier = application.bundleIdentifier ?? "unknown"
                        let duration = applicationActivity.totalActivityDuration
                        
                        let usageInfo = AppUsageInfo(
                            appName: appName,
                            bundleIdentifier: bundleIdentifier,
                            duration: duration,
                            category: getAppCategory(bundleIdentifier: bundleIdentifier)
                        )
                        
                        appUsageData.append(usageInfo)
                    }
                }
            }
        }
        
        let groupedData = Dictionary(grouping: appUsageData) { $0.bundleIdentifier }
            .map { (key, values) in
                let totalDuration = values.reduce(0) { $0 + $1.duration }
                let firstApp = values.first!
                return AppUsageInfo(
                    appName: firstApp.appName,
                    bundleIdentifier: firstApp.bundleIdentifier,
                    duration: totalDuration,
                    category: firstApp.category
                )
            }
        
        let sortedData = groupedData.sorted { $0.duration > $1.duration }
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = .dropAll
        
        let totalActivityDuration = await data.flatMap { $0.activitySegments }.reduce(0, {
            $0 + $1.totalActivityDuration
        })
        let totalActivityString = formatter.string(from: totalActivityDuration) ?? "No activity data"
        
        return CombinedActivityData(
            totalActivity: totalActivityString,
            appUsageData: AppUsageData(
                topFiveApps: Array(sortedData.prefix(5)),
                allApps: sortedData
            ), timePeriod: .today
        )
    }
}
