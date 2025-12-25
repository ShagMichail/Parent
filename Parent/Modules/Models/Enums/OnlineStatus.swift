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
            return String(localized: "Online")
        case .recent(let lastSeen):
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .full
            return String(localized: "Was online \(formatter.localizedString(for: lastSeen, relativeTo: Date()))")
        case .offline:
            return String(localized: "Offline")
        case .unknown:
            return String(localized: "Update...")
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
