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
            ZStack {
                Circle()
                    .stroke(model.childGender == "men" ? Color.backgroundMen.opacity(0.5) : Color.backgroundGirl.opacity(0.5), lineWidth: 10)
                Circle()
                    .fill(model.childGender == "men" ? Color.backgroundMen : Color.backgroundGirl)
                    .frame(width: 36, height: 36)
            }
            .frame(width: 40, height: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(model.childName)
                    .font(.custom("Inter-SemiBold", size: 18))
                    .foregroundColor(.blackText)
                
                Text(model.childAddress)
                    .font(.custom("Inter-Regular", size: 16))
                    .foregroundColor(.blackText)
            }
            
            Spacer()
            
            HStack(spacing: 4) {
                Image("battery-charging")
                    .frame(width: 24, height: 24)
                    .foregroundColor(model.childBatteryColor)
                Text(model.childBatteryLevel)
                    .font(.custom("Inter-Medium", size: 12))
                    .foregroundColor(.blackText)
            }
        }
    }
}
