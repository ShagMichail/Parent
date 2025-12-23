//
//  HourlyActivityModel.swift
//  Parent
//
//  Created by Michail Shagovitov on 10.12.2025.
//

import Foundation

struct HourlyActivityModel: Identifiable {
    var id: Int { hour }
    let hour: Int
    var duration: TimeInterval
    
    var hourLabel: String {
        return "\(hour):00"
    }
}

struct HourlyChartViewModel {
    let hourlyData: [HourlyActivityModel]
    let todayTotalDuration: TimeInterval
    let yesterdayTotalDuration: TimeInterval
}
