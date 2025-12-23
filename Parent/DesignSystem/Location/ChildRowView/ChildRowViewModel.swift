//
//  ChildRowViewModel.swift
//  Parent
//
//  Created by Michail Shagovitov on 23.12.2025.
//

import SwiftUI

struct ChildRowViewModel {
    let childName: String
    let childAddress: String
    let childBatteryLevel: String
    let childBatteryColor: Color
    
    init(childName: String, childAddress: String, childBatteryLevel: String, childBatteryColor: Color) {
        self.childName = childName
        self.childAddress = childAddress
        self.childBatteryLevel = childBatteryLevel
        self.childBatteryColor = childBatteryColor
    }
}
