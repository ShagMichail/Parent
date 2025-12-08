//
//  RoleCardViewModel.swift
//  Parent
//
//  Created by Михаил Шаговитов on 04.12.2025.
//

import SwiftUI

struct RoleCardViewModel {
    let title: String
    let imageName: String
    let isSelected: Bool
    
    init(title: String, imageName: String, isSelected: Bool) {
        self.title = title
        self.imageName = imageName
        self.isSelected = isSelected
    }
}

