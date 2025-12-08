//
//  ChildCardViewModel.swift
//  Parent
//
//  Created by Михаил Шаговитов on 05.12.2025.
//

import Foundation

struct ChildCardViewModel {
    let child: Child
    let isSelected: Bool
    
    init(child: Child, isSelected: Bool) {
        self.child = child
        self.isSelected = isSelected
    }
}
