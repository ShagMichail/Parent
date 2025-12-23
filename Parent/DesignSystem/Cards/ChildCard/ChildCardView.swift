//
//  ChildCardView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 05.12.2025.
//

import SwiftUI

struct ChildCardView: View {
    let model: ChildCardViewModel
    
    var body: some View {
        HStack(alignment: .center, spacing: 6) {
            Image(model.childImage)
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .background(model.childImage == "men-small" ? .backgroundMen : .backgroundGirl)
                .clipShape(Circle())

            
            VStack(alignment: .leading, spacing: 4) {
                Text(model.childName)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(.blackText)
                
                if model.showBatteryLevel {
                    HStack(spacing: 4) {
                        Image("battery-charging")
                            .frame(width: 24, height: 24)
                            .foregroundColor(model.batteryLevelColor ?? .chartStart)
                        Text((model.batteryLevel ?? "100"))
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.blackText)
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.white)
                    .stroke(model.isSelected ? .accent :  .white, lineWidth: 2)
            }
        )
        .shadow(
            color: Color.black.opacity(0.08),
            radius: 8,
            x: 0,
            y: 4
        )
    }
}

#Preview {
    ChildCardView(
        model: ChildCardViewModel(
            childName: "Michael",
            childImage: "men-small",
            isSelected: true,
            showBatteryLevel: true,
            batteryLevel: "34%",
            batteryLevelColor: .chartStart
        )
    )
    
    ChildCardView(
        model: ChildCardViewModel(
            childName: "Ekaterina",
            childImage: "girl-small",
            isSelected: true,
            showBatteryLevel: true,
            batteryLevel: "34%",
            batteryLevelColor: .chartStart
        )
    )
}
