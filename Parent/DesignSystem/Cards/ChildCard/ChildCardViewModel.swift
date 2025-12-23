//
//  ChildCardViewModel.swift
//  Parent
//
//  Created by Михаил Шаговитов on 05.12.2025.
//

import Foundation
import SwiftUI

struct ChildCardViewModel {
    let childName: String
    let childImage: String
    let isSelected: Bool
    let showBatteryLevel: Bool
    let batteryLevel: String?
    let batteryLevelColor: Color?
    
    init(childName: String, childImage: String, isSelected: Bool, showBatteryLevel: Bool, batteryLevel: String?, batteryLevelColor: Color?) {
        self.childName = childName
        self.childImage = childImage
        self.isSelected = isSelected
        self.showBatteryLevel = showBatteryLevel
        self.batteryLevel = batteryLevel
        self.batteryLevelColor = batteryLevelColor
    }
}
