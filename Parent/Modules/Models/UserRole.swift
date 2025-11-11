//
//  UserRole.swift
//  Parent
//
//  Created by Михаил Шаговитов on 10.11.2025.
//

enum UserRole: String, Codable {
    case parent
    case child
}

extension UserRole: Identifiable {
    var id: String { self.rawValue }
}
