//
//  Child.swift
//  Parent
//
//  Created by Михаил Шаговитов on 10.11.2025.
//

import Foundation
import FamilyControls

// Модель ребенка
struct Child: Identifiable, Codable {
    let id: UUID
    let name: String
    let deviceId: String
    var isOnline: Bool
    var lastActive: Date
    var restrictions: FamilyActivitySelection
    var timeLimit: TimeInterval
}
