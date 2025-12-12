////
////  PickupsReport.swift
////  Parent
////
////  Created by Михаил Шаговитов on 25.11.2025.
////
//
//import DeviceActivity
//import SwiftUI
//import ManagedSettings
//import Charts
//
//extension DeviceActivityReport.Context {
//    static let appPickups = Self("App Pickups Report")
//}
//
//struct AppPickupsReport: DeviceActivityReportScene, CommonFunctions {
//    let context: DeviceActivityReport.Context = .appPickups
//    let content: (AppPickupsData) -> AppPickupsChartView
//
//    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> AppPickupsData {
//        
//        var appPickups: [String: AppPickupInfo] = [:]
//        var totalPickups = 0
//        
//        for await deviceActivity in data {
//            for await activitySegment in deviceActivity.activitySegments {
//                for await categoryActivity in activitySegment.categories {
//                    for await applicationActivity in categoryActivity.applications {
//                        let application = applicationActivity.application
//                        guard let bundleIdentifier = application.bundleIdentifier else { continue }
//                        
//                        let appName = application.localizedDisplayName ?? bundleIdentifier
//                        let pickupCount = applicationActivity.numberOfPickups
//                        
//                        if pickupCount > 0 {
//                            totalPickups += pickupCount
//                            
//                            if let existing = appPickups[bundleIdentifier] {
//                                appPickups[bundleIdentifier] = AppPickupInfo(
//                                    appName: appName,
//                                    bundleIdentifier: bundleIdentifier,
//                                    pickupCount: existing.pickupCount + pickupCount,
//                                    category: getAppCategory(bundleIdentifier: bundleIdentifier)
//                                )
//                            } else {
//                                appPickups[bundleIdentifier] = AppPickupInfo(
//                                    appName: appName,
//                                    bundleIdentifier: bundleIdentifier,
//                                    pickupCount: pickupCount,
//                                    category: getAppCategory(bundleIdentifier: bundleIdentifier)
//                                )
//                            }
//                        }
//                    }
//                }
//            }
//        }
//        
//        let allApps = Array(appPickups.values)
//            .sorted { $0.pickupCount > $1.pickupCount }
//        
//        return AppPickupsData(
//            totalPickups: totalPickups,
//            topApps: Array(allApps.prefix(10)),
//            allApps: allApps
//        )
//    }
//}
