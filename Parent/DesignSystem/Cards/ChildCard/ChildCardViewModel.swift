//
//  ChildCardViewModel.swift
//  Parent
//
//  Created by Михаил Шаговитов on 05.12.2025.
//

import Foundation
import SwiftUI

struct ChildCardViewModel {
    let child: Child
    let isSelected: Bool
    let showBatteryLevel: Bool
    let batteryLevel: String?
    let batteryLevelColor: Color?
    
    init(child: Child, isSelected: Bool, showBatteryLevel: Bool, batteryLevel: String? = nil, batteryLevelColor: Color? = .green) {
        self.child = child
        self.isSelected = isSelected
        self.showBatteryLevel = showBatteryLevel
        self.batteryLevel = batteryLevel
        self.batteryLevelColor = batteryLevelColor
    }
}
