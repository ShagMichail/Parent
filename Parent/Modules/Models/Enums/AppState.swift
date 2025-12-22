//
//  AppState.swift
//  Parent
//
//  Created by Michail Shagovitov on 22.12.2025.
//

import Foundation

enum AppState {
    case authRequired       // Экран входа/регистрации
    case roleSelection      // Выбор роли (Родитель/Ребенок)
    case parentAddChild     // Родитель: Добавление первого ребенка
    case childPairing       // Ребенок: Ожидание привязки QR
    case parentDashboard    // Родитель: Главный экран
    case childDashboard     // Ребенок: Главный экран
    case accessDenied       // Доступ запрещен (нет прав ScreenTime)
}
