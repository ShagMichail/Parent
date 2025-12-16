//
//  EmptyStateTopAppsCardViewModel.swift
//  Parent
//
//  Created by Michail Shagovitov on 16.12.2025.
//

import Foundation

struct EmptyStateTopAppsCardViewModel {
    let iconName: String
    let message: String
    
    init(iconName: String, message: String) {
        self.iconName = iconName
        self.message = message
    }
}
