//
//  ActionTag.swift
//  Parent
//
//  Created by Michail Shagovitov on 11.12.2025.
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


struct ActionTag: View {
    let text: String
    let startColor: Color
    let endColor: Color
    let icon: String
    let isSelected: Bool // Теперь это вычисляемое свойство снаружи
    let onTap: () -> Void // Действие при нажатии
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                // Иконку показываем всегда или только у выбранного?
                // Сделаем всегда для красоты, или по вашему дизайну.
                Image(icon)
                    .resizable()
                    .frame(width: 16, height: 16)
                
                Text(text)
                    .font(.system(size: 16, weight: .regular))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                isSelected ? LinearGradient(
                    colors: [startColor, endColor],
                    startPoint: .leading,
                    endPoint: .trailing
                ) : LinearGradient(
                    colors: [Color.white, Color.white],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundColor(isSelected ? .white : startColor) // Или color, если хотите цветной текст
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.clear : startColor, lineWidth: 1)
            )
        }
    }
}
