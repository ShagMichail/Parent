//
//  ActionCategory.swift
//  Parent
//
//  Created by Michail Shagovitov on 16.12.2025.
//

import SwiftUI

enum ActionCategory: String, CaseIterable, Identifiable {
    case communication
    case chart
    case question
    case warning
    
    var name: String {
        switch self {
        case .communication: return String(localized: "Communication")
        case .chart: return String(localized: "Mode")
        case .question: return String(localized: "Suspicious activities")
        case .warning: return String(localized: "Critical Actions")
        }
    }
    var id: String { rawValue }
    
    // Цвет для тега и иконки
    var startColor: Color {
        switch self {
        case .communication: return Color.communicationStart
        case .chart: return Color.chartStart
        case .question: return Color.questionStart
        case .warning: return Color.warningStart
        }
    }
    
    var endColor: Color {
        switch self {
        case .communication: return Color.communicationEnd
        case .chart: return Color.chartEnd
        case .question: return Color.questionEnd
        case .warning: return Color.warningEnd
        }
    }
    
    // Иконка для тега
    var icon: String {
        switch self {
        case .communication: return "communication"
        case .chart: return "chart"
        case .question: return "question"
        case .warning: return "warning"
        }
    }
    
    // Текст заглушки, если действий нет
    var emptyStateText: String {
        switch self {
        case .communication: return String(localized: "Normal")
        case .chart: return String(localized: "The list of events is empty")
        case .question: return String(localized: "There are no important notifications")
        case .warning: return String(localized: "No critical threats detected")
        }
    }
}

