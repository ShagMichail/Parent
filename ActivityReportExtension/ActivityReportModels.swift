//
//  ActivityReportModels.swift
//  Parent
//
//  Created by Михаил Шаговитов on 14.11.2025.
//

import Foundation
import ManagedSettings

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

struct AppReportModel: Identifiable {
    let id: String
    let name: String
    let duration: TimeInterval
    let token: ApplicationToken?
}
