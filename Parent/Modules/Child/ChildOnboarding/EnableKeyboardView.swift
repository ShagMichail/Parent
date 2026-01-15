//
//  EnableKeyboardView.swift
//  Parent
//
//  Created by Michail Shagovitov on 15.01.2026.
//

import SwiftUI
// Пример View в основном приложении
struct EnableKeyboardView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Включите нашу клавиатуру")
                .font(.title)
            
            Text("1. Откройте Настройки")
            Text("2. Перейдите в Основные -> Клавиатура -> Клавиатуры")
            Text("3. Нажмите 'Новые клавиатуры...' и выберите 'LoggingKeyboard'")
            Text("4. Нажмите на 'LoggingKeyboard' в списке и включите 'Разрешить полный доступ'")
            
            // Кнопка, которая открывает настройки
            if let url = URL(string: UIApplication.openSettingsURLString) {
                Button("Перейти в Настройки") {
                    UIApplication.shared.open(url)
                }
            }
        }
        .padding()
    }
}
