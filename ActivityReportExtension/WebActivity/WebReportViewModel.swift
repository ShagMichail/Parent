//
//  WebUsageDetail.swift
//  Parent
//
//  Created by Michail Shagovitov on 23.12.2025.
//

// WebReportModels.swift
import Foundation
import ManagedSettings
import DeviceActivity

struct WebUsageDetail: Identifiable, Equatable, Hashable {
    var id: WebDomainToken { token }
    let token: WebDomainToken
    let totalDuration: TimeInterval
    let displayName: String
    let dailyUsage: [Date: TimeInterval]
    let hourlyUsage: [TimeInterval]
}

struct WebReportViewModel: Equatable {
    let hourlyData: [HourlyActivityModel]
    let dailyData: [DailyActivityModel]
    let websites: [WebUsageDetail]
    let totalDuration: TimeInterval
    let yesterdayTotalDuration: TimeInterval
    var isWeekView: Bool

    static func == (lhs: WebReportViewModel, rhs: WebReportViewModel) -> Bool {
        return lhs.isWeekView == rhs.isWeekView
    }
}
