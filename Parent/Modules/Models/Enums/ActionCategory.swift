//
//  ActionCategory.swift
//  Parent
//
//  Created by Michail Shagovitov on 16.12.2025.
//

import SwiftUI

enum ActionCategory: String, CaseIterable, Identifiable {
    case communication = "Общение"
    case chart = "Режим"
    case question = "Подозрительные действия"
    case warning = "Критические действия"
    
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
        case .communication: return "В норме"
        case .chart: return "Список событий пуст"
        case .question: return "Важных уведомлений нет"
        case .warning: return "Критических угроз не обнаружено"
        }
    }
}

