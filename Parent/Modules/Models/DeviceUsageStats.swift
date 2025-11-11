//
//  DeviceUsageStats.swift
//  Parent
//
//  Created by Михаил Шаговитов on 11.11.2025.
//

import Foundation

struct DeviceUsageStats {
    let totalScreenTime: TimeInterval
    let mostUsedApps: [String: TimeInterval]
    let sessionCount: Int
    let limitExceedances: Int
    let dailyUsage: [DailyUsage]
    let lastUpdated: Date
    
    var mostUsedApp: String? {
        mostUsedApps.max(by: { $0.value < $1.value })?.key
    }
}
