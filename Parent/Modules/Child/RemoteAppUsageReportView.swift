//
//  RemoteAppUsageReportView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 01.12.2025.
//

import SwiftUI

struct RemoteAppUsageReportView: View {
    let activityData: [String: Any]
    @State private var appUsageData = AppUsageData(topFiveApps: [], allApps: [])
    @State private var totalActivity = "0s"
    
    var body: some View {
        ScrollView {
            VStack {
                if appUsageData.allApps.isEmpty {
                    Text("Нет данных об использовании приложений")
                        .foregroundColor(.secondary)
                } else {
                    CombinedActivityView(
                        appUsageData: appUsageData,
                        totalActivity: totalActivity
                    )
                }
            }
        }
        .onAppear {
            parseActivityData()
        }
    }
    
    private func parseActivityData() {
        guard let appUsageArray = activityData["appUsage"] as? [[String: Any]] else { return }
        
        var allApps: [AppUsageInfo] = []
        
        for appData in appUsageArray {
            if let bundleId = appData["bundleId"] as? String,
               let name = appData["name"] as? String,
               let duration = appData["duration"] as? TimeInterval {
                
                let info = AppUsageInfo(
                    appName: name,
                    bundleIdentifier: bundleId,
                    duration: duration,
                    category: appData["category"] as? String ?? "Unknown"
                )
                allApps.append(info)
            }
        }
        
        let sortedApps = allApps.sorted { $0.duration > $1.duration }
        
        appUsageData = AppUsageData(
            topFiveApps: Array(sortedApps.prefix(5)),
            allApps: sortedApps
        )
        
        // Форматируем общее время
        let totalDuration = allApps.reduce(0) { $0 + $1.duration }
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated
        totalActivity = formatter.string(from: totalDuration) ?? "0s"
    }
}
