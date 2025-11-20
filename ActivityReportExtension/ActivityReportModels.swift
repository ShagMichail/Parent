//
//  ActivityReportModels.swift
//  Parent
//
//  Created by Михаил Шаговитов on 14.11.2025.
//

import Foundation

// Эти структуры теперь будут использоваться расширением
struct AppUsage: Identifiable {
    let id = UUID()
    let appName: String
    let duration: TimeInterval
    let bundleId: String
}

struct CategoryUsage: Identifiable {
    let id = UUID()
    let categoryName: String
    let duration: TimeInterval
}
