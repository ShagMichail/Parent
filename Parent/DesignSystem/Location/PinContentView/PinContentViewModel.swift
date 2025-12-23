//
//  PinContentViewModel.swift
//  Parent
//
//  Created by Michail Shagovitov on 23.12.2025.
//

import Foundation

struct PinContentViewModel {
    let child: Child
    let isSelected: Bool
    let onTap: () -> Void
    
    init(child: Child, isSelected: Bool, onTap: @escaping () -> Void) {
        self.child = child
        self.isSelected = isSelected
        self.onTap = onTap
    }
}
