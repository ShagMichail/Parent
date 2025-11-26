//
//  AppUsageChartView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 24.11.2025.
//

import SwiftUI

struct AppUsageChartView: View {
    let appUsageData: AppUsageData
    let totalActivity: String
    
    var body: some View {
        CombinedActivityView(appUsageData: appUsageData, totalActivity: totalActivity)
    }
}
