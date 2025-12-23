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
        AppUsageReport { model in
            AppUsageView(viewModel: model)
        }

        TopAppsCardReport { apps in
            TopAppsCardView(apps: apps)
        }
        
        HourlyChartReport { model in
            HourlyChartView(viewModel: model)
        }
        
        WebUsageReport { model in
            WebUsageView(viewModel: model)
        }
        
        CategoryUsageReport { model in
            CategoryUsageView(viewModel: model)
        }
    }
}
