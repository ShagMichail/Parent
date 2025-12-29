//
//  RestrictionItem.swift
//  Parent
//
//  Created by Michail Shagovitov on 29.12.2025.
//

import SwiftUI

struct RestrictionItem: Identifiable, Hashable {
    let id: String
    let title: String
    let description: String
    let iconName: String
    let count: Int?
    
    init(id: String, title: String, description: String, iconName: String, count: Int? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.iconName = iconName
        self.count = count
    }
}
