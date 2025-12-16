//
//  FieldValidationState.swift
//  Parent
//
//  Created by Michail Shagovitov on 16.12.2025.
//

import Foundation
/// Состояние валидации для одного поля
struct FieldValidationState {
    var isValid = false
    var error: String? = nil
}
