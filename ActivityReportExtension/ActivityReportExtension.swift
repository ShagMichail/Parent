//
//  ActivityReportExtension.swift
//  ActivityReportExtension
//
//  Created by Михаил Шаговитов on 14.11.2025.
//

import DeviceActivity
import SwiftUI

@main
struct ActivityReportExtension: DeviceActivityReportExtension {
    var body: some DeviceActivityReportScene {
        AppUsageReport { combinedData in
            AppUsageChartView(
                appUsageData: combinedData.appUsageData,
                totalActivity: combinedData.totalActivity
            )
        }
        
        AppNotificationsReport { appNotificationsData in
            AppNotificationsChartView(appNotificationsData: appNotificationsData)
        }
        
        AppPickupsReport { appPickupsData in
            AppPickupsChartView(appPickupsData: appPickupsData)
        }
    }
}

protocol CommonFunctions {
    func getAppCategory(bundleIdentifier: String) -> String
}

extension CommonFunctions {
    func getAppCategory(bundleIdentifier: String) -> String {
        let lowercasedBundle = bundleIdentifier.lowercased()
        
        if lowercasedBundle.contains("social") ||
            lowercasedBundle.contains("facebook") ||
            lowercasedBundle.contains("instagram") ||
            lowercasedBundle.contains("tiktok") ||
            lowercasedBundle.contains("twitter") ||
            lowercasedBundle.contains("snapchat") {
            return "Social Media"
        } else if lowercasedBundle.contains("game") ||
                    lowercasedBundle.contains("play") ||
                    lowercasedBundle.contains("gaming") {
            return "Games"
        } else if lowercasedBundle.contains("browser") ||
                    lowercasedBundle.contains("safari") ||
                    lowercasedBundle.contains("chrome") ||
                    lowercasedBundle.contains("firefox") {
            return "Browsers"
        } else if lowercasedBundle.contains("mail") ||
                    lowercasedBundle.contains("message") ||
                    lowercasedBundle.contains("whatsapp") ||
                    lowercasedBundle.contains("telegram") ||
                    lowercasedBundle.contains("signal") ||
                    lowercasedBundle.contains("slack") ||
                    lowercasedBundle.contains("discord") ||
                    lowercasedBundle.contains("viber") {
            return "Communication"
        } else if lowercasedBundle.contains("music") ||
                    lowercasedBundle.contains("spotify") ||
                    lowercasedBundle.contains("youtube") ||
                    lowercasedBundle.contains("netflix") ||
                    lowercasedBundle.contains("twitch") ||
                    lowercasedBundle.contains("video") ||
                    lowercasedBundle.contains("tv") {
            return "Entertainment"
        } else if lowercasedBundle.contains("notes") ||
                    lowercasedBundle.contains("pages") ||
                    lowercasedBundle.contains("numbers") ||
                    lowercasedBundle.contains("calendar") ||
                    lowercasedBundle.contains("reminder") ||
                    lowercasedBundle.contains("todo") ||
                    lowercasedBundle.contains("task") {
            return "Productivity"
        } else {
            return "Other"
        }
    }
}
