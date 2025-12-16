//
//  UserRole.swift
//  Parent
//
//  Created by Михаил Шаговитов on 10.11.2025.
//

enum UserRole: String, Codable, Identifiable {
    case parent
    case child
    case unknown
    
    var id: String { self.rawValue }
}

//extension UserRole: Identifiable {
//    var id: String { self.rawValue }
//}

enum AppState {
    case authRequired       // Экран входа/регистрации
    case roleSelection      // Выбор роли (Родитель/Ребенок)
    case parentAddChild     // Родитель: Добавление первого ребенка
    case childPairing       // Ребенок: Ожидание привязки QR
    case parentDashboard    // Родитель: Главный экран
    case childDashboard     // Ребенок: Главный экран
    case accessDenied       // Доступ запрещен (нет прав ScreenTime)
}
