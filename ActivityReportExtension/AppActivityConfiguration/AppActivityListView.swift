//
//  AppActivityListView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 14.11.2025.
//

import SwiftUI
import FamilyControls // Для доступа к ApplicationToken и иконкам
struct AppActivityListView: View {
    // Наш View теперь получает готовую, обработанную конфигурацию
    let configuration: AppActivityConfiguration
    var body: some View {
        VStack(alignment: .leading) {
            Text("Использование приложений")
                .font(.largeTitle.bold())
                .padding(.bottom)
            
            Text("Всего: \(formatTime(configuration.totalDuration))")
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.bottom)
            
            // Отображаем список приложений
            List(configuration.apps) { app in
                HStack {
                    // Используем токен, чтобы показать иконку приложения
                    Label(app.token)
                        .labelStyle(.iconOnly)
                        .frame(width: 40, height: 40)
                    
                    VStack(alignment: .leading) {
                        Text(app.appName).font(.headline)
                        Text("Использование").font(.subheadline).foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text(formatTime(app.duration))
                        .foregroundColor(.secondary)
                }
            }
            .listStyle(.plain) // Убираем стандартные рамки списка
        }
        .padding()
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: timeInterval) ?? "0m"
    }
}
