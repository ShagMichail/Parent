//
//  NotificationCard.swift
//  Parent
//
//  Created by Michail Shagovitov on 14.01.2026.
//

import SwiftUI

struct NotificationCard: View {
    let notification: ChildNotification
    
    private var iconName: String {
        switch notification.type {
        case .commandExecuted: return "lock-command"
        case .commandFailed: return "lock-command"
        case .blockAll: return "lock-command"
        case .unblockAll: return "unlock-command"
        case .locationUpdated: return "current-location"
        case .scheduleUpdated: return "focus-command"
        case .scheduleDelete: return "focus-command"
        case .webBlockUpdate: return "web-command"
        case .appBlockUpdate: return "apps-command"
        case .limitsAppUpdate: return "limit-command"
        }
    }
    
    private var iconColor: Color {
        switch notification.type {
        case .commandExecuted: return .chartStart
        case .commandFailed: return .errorMessage
        case .blockAll: return .errorMessage
        case .unblockAll: return .chartStart
        case .locationUpdated: return .accent
        case .scheduleUpdated: return .questionStart
        case .scheduleDelete: return .questionStart
        case .webBlockUpdate: return .questionStart
        case .appBlockUpdate: return .questionStart
        case .limitsAppUpdate: return  .questionStart
        }
    }
    
    
    private var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.localizedString(for: notification.date, relativeTo: Date())
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Image(iconName)
                    .resizable()
                    .frame(width: 45, height: 45)
                    .foregroundColor(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(notification.title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text(timeAgo)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                
                Text(notification.message)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            if !notification.isRead {
                Circle()
                    .fill(Color.warningStart)
                    .frame(width: 8, height: 8)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(
                    color: Color.black.opacity(0.08),
                    radius: 8,
                    x: 0,
                    y: 4
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(notification.isRead ? Color.clear : iconColor, lineWidth: 2)
        )
        .contentShape(Rectangle())
    }
}
