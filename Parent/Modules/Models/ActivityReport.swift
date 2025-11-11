//
//  ActivityReport.swift
//  Parent
//
//  Created by Михаил Шаговитов on 11.11.2025.
//

import Foundation

struct ActivityReport {
    let totalScreenTime: TimeInterval
    let mostUsedApps: [String: TimeInterval]
    let limitExceedances: Int
    let lastUpdated: Date
}
