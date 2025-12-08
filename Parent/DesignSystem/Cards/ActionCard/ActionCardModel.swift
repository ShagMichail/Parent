//
//  ActionCardModel.swift
//  Parent
//
//  Created by Михаил Шаговитов on 05.12.2025.
//

import Foundation

struct ActionCardModel {
    let title: String
    let icon: String
    let status: String?
    let showsArrow: Bool?
    let action: () -> Void
    
    init(title: String, icon: String, status: String? = nil, showsArrow: Bool? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.status = status
        self.showsArrow = showsArrow
        self.action = action
    }
}
