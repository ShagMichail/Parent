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
        case .locationUpdated: return "location-big"
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
    
    private func format(date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        
        // --- 1. Было ли это СЕГОДНЯ ---
        if calendar.isDateInToday(date) {
            let components = calendar.dateComponents([.hour, .minute, .second], from: date, to: now)
            
            let relativeFormatter = RelativeDateTimeFormatter()
            relativeFormatter.unitsStyle = .full
            relativeFormatter.locale = Locale(identifier: "ru_RU")
            
            if let hours = components.hour, hours < 1 {
                return relativeFormatter.localizedString(for: date, relativeTo: now)
            }
            
            let preciseFormatter = DateComponentsFormatter()
            preciseFormatter.unitsStyle = .abbreviated // "1ч 15м"
            preciseFormatter.allowedUnits = [.hour, .minute]
            preciseFormatter.calendar?.locale = Locale(identifier: "ru_RU")
            if let formatted = preciseFormatter.string(from: date, to: now) {
                return "\(formatted) назад"
            } else {
                return relativeFormatter.localizedString(for: date, relativeTo: now)
            }
        }
        
        // --- 2. Было ли это ВЧЕРА ---
        if calendar.isDateInYesterday(date) {
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm"
            let timeString = timeFormatter.string(from: date)
            return "Вчера, \(timeString)"
        }
        
        // --- 3. Если это было еще раньше ---
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy, HH:mm"
        return dateFormatter.string(from: date)
    }

    var body: some View {
        HStack(alignment: .top, spacing: 15) {
    
            Image(iconName)
                .frame(width: 45, height: 45)
                .foregroundColor(iconColor)
            
            VStack(alignment: .leading) {
                    Text(notification.title)
                        .font(.custom("Inter-Medium", size: 16))
                        .foregroundColor(.blackText)
                        .padding(.bottom, 4)
                Text(notification.message)
                    .font(.custom("Inter-Regular", size: 14))
                    .foregroundColor(.strokeTextField)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, 10)
                
                Text(format(date: notification.date))
                    .font(.custom("Inter-Regular", size: 14))
                    .foregroundColor(.strokeTextField)
            }
            
            Spacer()
            
            if !notification.isRead {
                Circle()
                    .fill(Color.warningStart)
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
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


#Preview {
    ScrollView {
        VStack(spacing: 20) {
            Text("Непрочитанные уведомления")
                .font(.title2.bold())
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // --- 1. Блокировка (непрочитанное) ---
            NotificationCard(notification: .mock(type: .blockAll, isRead: false, date: Date().addingTimeInterval(-16400)))
            
            // --- 2. Разблокировка (непрочитанное) ---
            NotificationCard(notification: .mock(type: .unblockAll, isRead: false, date: Date().addingTimeInterval(-6400)))
            
            // --- 3. Обновление локации (непрочитанное) ---
            NotificationCard(notification: .mock(type: .locationUpdated, isRead: false, date: Date().addingTimeInterval(-400)))
            
            // --- 4. Обновление лимитов (непрочитанное) ---
            NotificationCard(notification: .mock(type: .limitsAppUpdate, isRead: false, date: Date().addingTimeInterval(-10)))
            
            Divider().padding(.vertical)
            
            Text("Прочитанные уведомления")
                .font(.title2.bold())
                .frame(maxWidth: .infinity, alignment: .leading)

            // --- 5. Расписание (прочитанное) ---
            NotificationCard(notification: .mock(type: .scheduleUpdated, isRead: true, date: Date().addingTimeInterval(-16400)))
            
            // --- 6. Блокировка сайтов (прочитанное, вчера) ---
            NotificationCard(notification: .mock(type: .webBlockUpdate, isRead: true, date: Date().addingTimeInterval(-86400)))
            
            // --- 7. Ошибка команды (прочитанное) ---
            NotificationCard(notification: .mock(type: .commandFailed, isRead: true, date: Date().addingTimeInterval(-1116400)))
        }
        .padding()
    }
    .background(Color(.systemGray6))
}

extension ChildNotification {
    
    static func mock(
        type: NotificationType,
        isRead: Bool,
        childId: String = "child_123",
        childName: String = "Антон",
        date: Date = Date()
    ) -> ChildNotification {
        
        var title: String
        var message: String
        var commandName: String? = type.rawValue
        
        switch type {
        case .blockAll:
            title = "Устройство заблокировано"
            message = "Вы полностью заблокировали устройство \(childName)."
        case .unblockAll:
            title = "Устройство разблокировано"
            message = "Вы сняли полную блокировку с устройства \(childName)."
        case .locationUpdated:
            title = "Локация обновлена"
            message = "\(childName) отправил(а) свое текущее местоположение."
        case .limitsAppUpdate:
            title = "Лимиты приложений обновлены"
            message = "Вы изменили дневные лимиты использования для \(childName)."
        case .commandFailed:
            title = "Ошибка команды"
            message = "Не удалось заблокировать устройство. Проверьте подключение."
            commandName = "block_all"
        case .scheduleUpdated:
            title = "Расписание изменено"
            message = "Режим фокусировки для \(childName) был обновлен."
        case .webBlockUpdate:
            title = "Блокировка сайтов"
            message = "Список заблокированных сайтов был изменен."
        case .appBlockUpdate:
            title = "Блокировка приложений"
            message = "Список заблокированных приложений изменен."
        case .scheduleDelete:
            title = "Расписание удалено"
            message = "Один из режимов фокусировки был удален."
        case .commandExecuted:
            title = "Команда выполнена"
            message = "Ребенок выполнил команду."
        }
        
        return ChildNotification(
            childId: childId,
            childName: childName,
            type: type,
            title: title,
            message: message,
            date: date,
            isRead: isRead,
            commandName: commandName,
            commandStatus: isRead ? "executed" : "pending",
            recordID: UUID().uuidString
        )
    }
}
