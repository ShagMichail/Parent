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
        // Create a report for each DeviceActivityReport.Context that your app supports.
        TotalActivityReport { totalActivity in
            TotalActivityView(totalActivity: totalActivity)
        }
        // Add more reports here...
    }
}
