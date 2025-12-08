//
//  InfoCardModel.swift
//  Parent
//
//  Created by Михаил Шаговитов on 05.12.2025.
//

import Foundation
import SwiftUI

struct InfoCardModel {
    let title: String
    let icon: String
    let location: String
    let status: String
    let statusColor: Color
    
    init(title: String, icon: String, location: String, status: String, statusColor: Color) {
        self.title = title
        self.icon = icon
        self.location = location
        self.status = status
        self.statusColor = statusColor
    }
}

