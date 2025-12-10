//
//  FocusScheduleCard.swift
//  Parent
//
//  Created by Михаил Шаговитов on 08.12.2025.
//

import SwiftUI

struct KnobColorToggleStyle: ToggleStyle {
    var activeColor: Color = .purple
    var inactiveKnobColor: Color = .white
    var trackColor: Color = Color(uiColor: .systemGray5)
    
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            // Текст метки (если есть)
            configuration.label
            
            // Сам переключатель
            ZStack(alignment: configuration.isOn ? .trailing : .leading) {
                Capsule()
                    .fill(trackColor)
                    .frame(width: 51, height: 31)
                
                Circle()
                    .fill(configuration.isOn ? activeColor : inactiveKnobColor)
                    .frame(width: 27, height: 27)
                    .padding(2) // Отступ от края
                    .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1) // Тень для объема
            }
            .onTapGesture {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    configuration.isOn.toggle()
                }
            }
        }
    }
}
