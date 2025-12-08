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
    let action: () -> Void
    
    init(title: String, isEnabled: Bool, action: @escaping () -> Void) {
        self.title = title
        self.isEnabled = isEnabled
        self.action = action
    }
}

