//
//  HelpTopic.swift
//  Parent
//
//  Created by Michail Shagovitov on 16.01.2026.
//

import Foundation

enum HelpTopic: String, CaseIterable, Identifiable {
    case notifications
    case location
    case keyboard
    
    var id: String { self.rawValue }
    
    var iconName: String {
        switch self {
        case .notifications: return "bell.badge.fill"
        case .location: return "location.fill"
        case .keyboard: return "keyboard.fill"
        }
    }
    
    var topicName: String {
        switch self {
        case .notifications: return String(localized: "Notifications")
        case .location: return String(localized: "Location")
        case .keyboard: return String(localized: "Keyboard")
        }
    }
    
    var topicOn: String {
        switch self {
        case .notifications: return String(localized: "Turn on notifications on the child's device")
        case .location: return String(localized: "Turn on geolocation on the child's device")
        case .keyboard: return String(localized: "Turn on the special keyboard on the child's device")
        }
    }
    
    var topicDescription: String {
        switch self {
        case .notifications:
            return String(localized: "Notifications are necessary so that the child's device can instantly receive commands from you, for example, about blocking, updating schedules or limits.")
        case .location:
            return String(localized: "Geolocation access allows you to request the coordinates of your child's device in real time and determine where your child is located.")
        case .keyboard:
            return String(localized: "A special keyboard allows you to analyze the entered text to prevent dangerous situations.")
        }
    }
}
