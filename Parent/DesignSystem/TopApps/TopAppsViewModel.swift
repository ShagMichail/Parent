//
//  TopAppsViewModel.swift
//  Parent
//
//  Created by Михаил Шаговитов on 05.12.2025.
//

import Foundation

struct TopAppsViewModel: Identifiable {
    let id: UUID
    let icon: String
    let nameApps: String
    let time: String
    
    init(icon: String, nameApps: String, time: String) {
        self.id = UUID()
        self.icon = icon
        self.nameApps = nameApps
        self.time = time
    }
}

