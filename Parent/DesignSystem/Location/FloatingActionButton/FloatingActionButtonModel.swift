//
//  FloatingActionButtonModel.swift
//  Parent
//
//  Created by Michail Shagovitov on 23.12.2025.
//

import Foundation

struct FloatingActionButtonModel {
    let iconName: String
    let action: () -> Void
    
    init(iconName: String, action: @escaping () -> Void) {
        self.iconName = iconName
        self.action = action
    }
}
