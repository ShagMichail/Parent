//
//  PasswordValidationState.swift
//  Parent
//
//  Created by Michail Shagovitov on 16.12.2025.
//

import Foundation

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
