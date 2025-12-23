//
//  UserRole.swift
//  Parent
//
//  Created by Michail Shagovitov on 22.12.2025.
//

import Foundation

enum UserRole: String, Codable, Identifiable {
    case parent
    case child
    case men
    case girl
    case unknown
    
    var id: String { self.rawValue }
}
