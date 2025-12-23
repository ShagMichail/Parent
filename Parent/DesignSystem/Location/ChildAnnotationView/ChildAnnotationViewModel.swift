//
//  ChildAnnotationViewModel.swift
//  Parent
//
//  Created by Michail Shagovitov on 23.12.2025.
//

import Foundation

struct ChildAnnotationViewModel {
    let name: String
    let gender: String
    let isSelected: Bool
    
    init(name: String, gender: String, isSelected: Bool) {
        self.name = name
        self.gender = gender
        self.isSelected = isSelected
    }
}
