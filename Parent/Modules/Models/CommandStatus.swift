//
//  CommandStatus.swift
//  Parent
//
//  Created by Михаил Шаговитов on 26.11.2025.
//

import Foundation

//struct CommandStatus: Codable {
//    let recordID: String
//    let commandName: String
//    let targetChildID: String
//    let sentAt: Date
//    var status: Status
//    var updatedAt: Date
//    var lastChecked: Date
//    var attempts: Int
//    
//    enum Status: String, Codable {
//        case pending = "pending"      // Отправлена родителем
//        case delivered = "delivered"  // Получена ребенком
//        case executing = "executing"  // Выполняется на устройстве
//        case executed = "executed"    // Успешно выполнена
//        case failed = "failed"        // Ошибка выполнения
//        case timeout = "timeout"      // Таймаут (запись удалена ребенком)
//        case notFound = "not_found"   // Запись не найдена (скорее всего выполнена)
//    }
//}
