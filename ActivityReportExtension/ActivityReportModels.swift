//
//  ActivityReportModels.swift
//  Parent
//
//  Created by Михаил Шаговитов on 14.11.2025.
//

import Foundation

struct CombinedActivityData {
    let totalActivity: String
    let appUsageData: AppUsageData
    let timePeriod: TimePeriod
}

enum TimePeriod: String, CaseIterable {
    case today = "Today"
    case week = "This Week"
    case month = "This Month"
    
    var displayName: String {
        return self.rawValue
    }
}

struct AppUsageData {
    let topFiveApps: [AppUsageInfo]
    let allApps: [AppUsageInfo]
}

struct AppUsageInfo: Identifiable {
    let id = UUID()
    let appName: String
    let bundleIdentifier: String
    let duration: TimeInterval
    let category: String
}

struct AppNotificationsData {
    let totalNotifications: Int
    let topApps: [AppNotificationInfo]
    let allApps: [AppNotificationInfo]
}

struct AppNotificationInfo: Identifiable {
    let id = UUID()
    let appName: String
    let bundleIdentifier: String
    let notificationCount: Int
    let category: String
}

struct AppPickupsData {
    let totalPickups: Int
    let topApps: [AppPickupInfo]
    let allApps: [AppPickupInfo]
}

struct AppPickupInfo: Identifiable {
    let id = UUID()
    let appName: String
    let bundleIdentifier: String
    let pickupCount: Int
    let category: String
}

struct CategoryData: Identifiable {
    let id = UUID()
    let name: String
    let duration: TimeInterval
}
