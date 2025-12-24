//
//  ActionTag.swift
//  Parent
//
//  Created by Michail Shagovitov on 11.12.2025.
//

import SwiftUI

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
                    .font(.custom("Inter-Regular", size: 16))
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
