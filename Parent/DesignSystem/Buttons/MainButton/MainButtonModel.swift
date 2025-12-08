//
//  MainButtonModel.swift
//  Parent
//
//  Created by Михаил Шаговитов on 03.12.2025.
//

import SwiftUI

struct MainButtonModel {
    let title: String
    let font: Font
    let foregroundColor: Color
    let cornerRadius: CGFloat
    let background: Color
    let strokeColor: Color
    let strokeLineWidth: CGFloat
    
    init(title: String, font: Font, foregroundColor: Color, cornerRadius: CGFloat, background: Color, strokeColor: Color, strokeLineWidth: CGFloat) {
        self.title = title
        self.font = font
        self.foregroundColor = foregroundColor
        self.cornerRadius = cornerRadius
        self.background = background
        self.strokeColor = strokeColor
        self.strokeLineWidth = strokeLineWidth
    }
}
