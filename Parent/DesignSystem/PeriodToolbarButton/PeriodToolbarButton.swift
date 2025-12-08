//
//  PeriodToolbarButton.swift
//  Parent
//
//  Created by Михаил Шаговитов on 02.12.2025.
//

import SwiftUI

struct PeriodToolbarButton: View {
    let period: TimePeriod
    let isSelected: Bool
    let action: () -> Void
    let model: PeriodToolbarButtonModel
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: period.icon)
                    .font(.caption)
                    .foregroundColor(isSelected ? model.selectedIconColor : model.unselectedIconColor)
                
                Text(period.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? model.selectedTextColor : model.unselectedTextColor)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(isSelected ? model.selectedBackgroundColor : model.unselectedBackgroundColor)
            )
            .overlay(
                Capsule()
                    .stroke(isSelected ? model.selectedBorderColor : model.unselectedBorderColor, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
