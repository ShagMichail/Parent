//
//  ContinueButtonModel.swift
//  Parent
//
//  Created by Михаил Шаговитов on 04.12.2025.
//

import SwiftUI

struct ContinueButtonModel {
    let title: String
    let isEnabled: Bool
    let isBackground: Bool
    let textColor: Color
    let fullWidth: Bool
    let action: () -> Void
    
    init(
        title: String,
        isEnabled: Bool,
        isBackground: Bool = true,
        textColor: Color = Color.white,
        fullWidth: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isEnabled = isEnabled
        self.isBackground = isBackground
        self.textColor = textColor
        self.fullWidth = fullWidth
        self.action = action
    }
}

