//
//  WeeklyChartReport.swift
//  Parent
//
//  Created by Michail Shagovitov on 10.12.2025.
//

import DeviceActivity
import SwiftUI
import ManagedSettings

extension DeviceActivityReport.Context {
    static let hourlyActivityChart = Self("Hourly Activity Chart")
}

struct HourlyChartReport: DeviceActivityReportScene {
    let context: DeviceActivityReport.Context = .hourlyActivityChart
    let content: (HourlyChartViewModel) -> HourlyChartView
    
    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> HourlyChartViewModel {
        let defaults = UserDefaults(suiteName: "group.com.laborato.test.Parent")
        let childAppleID = defaults?.string(forKey: "myChildAppleID")
        
        var hourlyData = (0..<24).map { HourlyActivityModel(hour: $0, duration: 0) }
        var appsDict: [ApplicationToken: TimeInterval] = [:]
        
        var todayTotal: TimeInterval = 0
        var yesterdayTotal: TimeInterval = 0
        
        let calendar = Calendar.current
        
        for await deviceActivity in data {
            if deviceActivity.user.appleID == childAppleID {
                for await segment in deviceActivity.activitySegments {
                    let segmentStart = segment.dateInterval.start
                    let segmentDuration = segment.totalActivityDuration
                    
                    if calendar.isDateInToday(segmentStart) {
                        todayTotal += segmentDuration
                        
                        let hour = calendar.component(.hour, from: segmentStart)
                        if hour >= 0 && hour < 24 {
                            hourlyData[hour] = HourlyActivityModel(hour: hour, duration: hourlyData[hour].duration + segmentDuration)
                        }
                        
                        for await category in segment.categories {
                            for await app in category.applications {
                                let appDuration = app.totalActivityDuration
                                let token = app.application.token
                                if let token = token, appDuration > 0 {
                                    appsDict[token, default: 0] += appDuration
                                }
                            }
                        }
                        
                    } else if calendar.isDateInYesterday(segmentStart) {
                        yesterdayTotal += segmentDuration
                    }
                }
            }
        }
        
        return HourlyChartViewModel(
            hourlyData: hourlyData,
            todayTotalDuration: todayTotal,
            yesterdayTotalDuration: yesterdayTotal
        )
    }
}
