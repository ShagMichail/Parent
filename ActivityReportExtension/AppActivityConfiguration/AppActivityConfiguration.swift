//
//  AppActivityConfiguration.swift
//  Parent
//
//  Created by Михаил Шаговитов on 14.11.2025.
//

import Foundation
import ManagedSettings

// Эта структура будет "конфигурацией" для нашего View.
// Она содержит только те данные, которые нужны для отображения.
struct AppActivityConfiguration {
    let totalDuration: TimeInterval
    let apps: [AppUsage]
    
    // Вложенная структура для удобства
    struct AppUsage: Identifiable {
        let id = UUID()
        let appName: String
        let duration: TimeInterval
        let token: ApplicationToken // Сохраняем токен, чтобы можно было получить иконку
    }
}
