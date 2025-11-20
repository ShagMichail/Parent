//
//  FamilyError.swift
//  Parent
//
//  Created by Михаил Шаговитов on 11.11.2025.
//

import Foundation

enum FamilyError: Error, LocalizedError {
    case authorizationDenied
    case authorizationFailed(Error)
    case unknownAuthorizationStatus
    case notAuthorized
    case insufficientPermissions
    case noFamilyMembersFound
    
    var errorDescription: String? {
        switch self {
        case .authorizationDenied:
            return "Доступ к Family Sharing запрещен"
        case .authorizationFailed(let error):
            return "Ошибка авторизации: \(error.localizedDescription)"
        case .unknownAuthorizationStatus:
            return "Неизвестный статус авторизации"
        case .notAuthorized:
            return "Требуется авторизация"
        case .insufficientPermissions:
            return "Недостаточно прав для выполнения операции"
        case .noFamilyMembersFound:
            return "Члены семьи не найдены"
        }
    }
}
