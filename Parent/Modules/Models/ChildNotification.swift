//
//  AppNotification.swift
//  Parent
//
//  Created by Michail Shagovitov on 14.01.2026.
//

import Foundation
import CloudKit

struct ChildNotification: Identifiable, Equatable, Codable {
    let id: UUID
    let childId: String
    let childName: String
    let type: NotificationType
    let title: String
    let message: String
    let date: Date
    var isRead: Bool
    let commandName: String?
    let commandStatus: String?
    let recordID: String?
    
    enum NotificationType: String, Codable {
        case commandExecuted = "command_executed"
        case commandFailed = "command_failed"
        case blockAll = "block_all"
        case unblockAll = "unblock_all"
        case locationUpdated = "location_updated"
        case scheduleUpdated = "schedule_updated"
        case scheduleDelete = "schedule_delete"
        case webBlockUpdate = "web-block-update"
        case limitsAppUpdate = "limits-app-update"
        case appBlockUpdate = "app-block-update"
    }
    
    init(id: UUID = UUID(),
         childId: String,
         childName: String,
         type: NotificationType,
         title: String,
         message: String,
         date: Date = Date(),
         isRead: Bool = false,
         commandName: String? = nil,
         commandStatus: String? = nil,
         recordID: String? = nil) {
        self.id = id
        self.childId = childId
        self.childName = childName
        self.type = type
        self.title = title
        self.message = message
        self.date = date
        self.isRead = isRead
        self.commandName = commandName
        self.commandStatus = commandStatus
        self.recordID = recordID
    }
    
    // Инициализатор для создания уведомления из CloudKit записи
    init?(record: CKRecord, child: Child) {
        guard let typeRaw = record["type"] as? String,
              let type = NotificationType(rawValue: typeRaw),
              let title = record["title"] as? String,
              let message = record["message"] as? String,
              let date = record["date"] as? Date else {
            return nil
        }
        
        self.id = UUID(uuidString: record.recordID.recordName) ?? UUID()
        self.childId = child.recordID
        self.childName = child.name
        self.type = type
        self.title = title
        self.message = message
        self.date = date
        self.isRead = record["isRead"] as? Bool ?? false
        self.commandName = record["commandName"] as? String
        self.commandStatus = record["commandStatus"] as? String
        self.recordID = record.recordID.recordName
    }
}
