//
//  ChildRowView.swift
//  Parent
//
//  Created by Michail Shagovitov on 16.12.2025.
//

import SwiftUI

struct ChildRowView: View {
    let model: ChildRowViewModel
    
    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(Color.blue.opacity(0.5))
                .frame(width: 40, height: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(model.childName)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                Text(model.childAddress)
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            HStack(spacing: 4) {
                Image("battery-charging")
                    .frame(width: 24, height: 24)
                    .foregroundColor(model.childBatteryColor)
                Text(model.childBatteryLevel)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.blackText)
            }
        }
    }
}
