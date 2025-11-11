//
//  MemberType.swift
//  Parent
//
//  Created by Михаил Шаговитов on 11.11.2025.
//

enum MemberType: String, Codable, CaseIterable, Identifiable {
    case parent = "parent"
    case child = "child"
    case unknown = "unknown"
    
    // Добавляем идентификатор для Identifiable
    var id: String { self.rawValue }

    var description: String {
        switch self {
        case .parent: return "Родитель"
        case .child: return "Ребенок"
        case .unknown: return "Не определен"
        }
    }
}
