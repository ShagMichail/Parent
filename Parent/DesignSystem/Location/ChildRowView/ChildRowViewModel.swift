//
//  ChildRowViewModel.swift
//  Parent
//
//  Created by Michail Shagovitov on 23.12.2025.
//

import SwiftUI

struct ChildRowViewModel {
    let childName: String
    let childGender: String
    let childAddress: String
    let childBatteryLevel: String
    let childBatteryColor: Color
    
    init(childName: String, childGender: String, childAddress: String, childBatteryLevel: String, childBatteryColor: Color) {
        self.childName = childName
        self.childGender = childGender
        self.childAddress = childAddress
        self.childBatteryLevel = childBatteryLevel
        self.childBatteryColor = childBatteryColor
    }
}
