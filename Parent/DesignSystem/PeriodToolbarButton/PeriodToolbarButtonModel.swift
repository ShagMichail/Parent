//
//  PeriodToolbarButtonModel.swift
//  Parent
//
//  Created by Михаил Шаговитов on 02.12.2025.
//

import SwiftUI

struct PeriodToolbarButtonModel {
    var selectedBackgroundColor: Color
    var unselectedBackgroundColor: Color
    var selectedTextColor: Color
    var unselectedTextColor: Color
    var selectedIconColor: Color
    var unselectedIconColor: Color
    var selectedBorderColor: Color
    var unselectedBorderColor: Color
    
    init(selectedBackgroundColor: Color, unselectedBackgroundColor: Color, selectedTextColor: Color, unselectedTextColor: Color, selectedIconColor: Color, unselectedIconColor: Color, selectedBorderColor: Color, unselectedBorderColor: Color) {
        self.selectedBackgroundColor = selectedBackgroundColor
        self.unselectedBackgroundColor = unselectedBackgroundColor
        self.selectedTextColor = selectedTextColor
        self.unselectedTextColor = unselectedTextColor
        self.selectedIconColor = selectedIconColor
        self.unselectedIconColor = unselectedIconColor
        self.selectedBorderColor = selectedBorderColor
        self.unselectedBorderColor = unselectedBorderColor
    }
}
