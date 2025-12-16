//
//  CachedFocusSchedule.swift
//  Parent
//
//  Created by Michail Shagovitov on 16.12.2025.
//

import Foundation

struct CachedFocusSchedule: Codable {
    let id: UUID
    let startTime: Date
    let endTime: Date
    let daysOfWeek: [CachedWeekday] // Используем упрощенный enum или Int
    let isEnabled: Bool
    
    // Зеркало вашего Enum Weekday для Codable совместимости
    enum CachedWeekday: Int, Codable {
        case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday
    }
}
