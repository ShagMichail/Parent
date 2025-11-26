//
//  NotificationsReport.swift
//  Parent
//
//  Created by Михаил Шаговитов on 24.11.2025.
//

import DeviceActivity
import SwiftUI
import ManagedSettings
import Charts
import UserNotifications

extension DeviceActivityReport.Context {
    static let appNotifications = Self("App Notifications Report")
}

struct AppNotificationsReport: DeviceActivityReportScene, CommonFunctions {
    let context: DeviceActivityReport.Context = .appNotifications
    let content: (AppNotificationsData) -> AppNotificationsChartView

    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> AppNotificationsData {
        
        var appNotifications: [String: AppNotificationInfo] = [:]
        var totalNotifications = 0
        
        for await deviceActivity in data {
            for await activitySegment in deviceActivity.activitySegments {
                for await categoryActivity in activitySegment.categories {
                    for await applicationActivity in categoryActivity.applications {
                        let application = applicationActivity.application
                        guard let bundleIdentifier = application.bundleIdentifier else { continue }
                        
                        let appName = application.localizedDisplayName ?? bundleIdentifier
                        let notificationCount = applicationActivity.numberOfNotifications
                        
                        if notificationCount > 0 {
                            totalNotifications += notificationCount
                            
                            if let existing = appNotifications[bundleIdentifier] {
                                appNotifications[bundleIdentifier] = AppNotificationInfo(
                                    appName: appName,
                                    bundleIdentifier: bundleIdentifier,
                                    notificationCount: existing.notificationCount + notificationCount,
                                    category: getAppCategory(bundleIdentifier: bundleIdentifier)
                                )
                            } else {
                                appNotifications[bundleIdentifier] = AppNotificationInfo(
                                    appName: appName,
                                    bundleIdentifier: bundleIdentifier,
                                    notificationCount: notificationCount,
                                    category: getAppCategory(bundleIdentifier: bundleIdentifier)
                                )
                            }
                        }
                    }
                }
            }
        }
        
        let allApps = Array(appNotifications.values)
            .sorted { $0.notificationCount > $1.notificationCount }
        
        return AppNotificationsData(
            totalNotifications: totalNotifications,
            topApps: Array(allApps.prefix(5)),
            allApps: allApps
        )
    }
}
