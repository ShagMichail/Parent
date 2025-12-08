//
//  Models.swift
//  Parent
//
//  Created by Михаил Шаговитов on 03.12.2025.
//

import Foundation

// Определяет тип экрана
enum AuthMode {
    case login
    case register
}

// Хранит данные, которые вводит пользователь
struct AuthCredentials {
    var email = ""
    var password = ""
    var confirmPassword = ""
}

/// Состояние валидации для одного поля
struct FieldValidationState {
    var isValid = false
    var error: String? = nil
}

/// Состояние валидации для полей пароля
struct PasswordValidationState {
    var isLongEnough = false
    var hasCapitalAndDigit = false
    var passwordsMatch = false
    
    var isPasswordValid: Bool {
        isLongEnough && hasCapitalAndDigit
    }
    
    var isPasswordSectionValid: Bool {
        isPasswordValid && passwordsMatch
    }
}
