//
//  OnlineStatus.swift
//  Parent
//
//  Created by Michail Shagovitov on 16.12.2025.
//

import SwiftUI

enum OnlineStatus {
    case online
    case recent(lastSeen: Date)
    case offline
    case unknown

    var text: String {
        switch self {
        case .online:
            return "Онлайн"
        case .recent(let lastSeen):
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .full
            return "Был(а) в сети \(formatter.localizedString(for: lastSeen, relativeTo: Date()))"
        case .offline:
            return "Офлайн"
        case .unknown:
            return "Обновление..."
        }
    }
    
    var color: Color {
        switch self {
        case .online: return .chartStart
        case .recent: return .questionStart
        case .offline: return .warningStart
        case .unknown: return .strokeTextField
        }
    }
}
