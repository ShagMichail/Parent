//
//  CustomPicker.swift
//  Parent
//
//  Created by Michail Shagovitov on 12.12.2025.
//

import SwiftUI

struct CustomSegmentedControl: View {
    @Binding var selection: Int
    let options: [String]
    
    let activeColor = Color.accent
    let backgroundColor = Color.backgroundPicker
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(options.indices, id: \.self) { index in
                
                let isSelected = (selection == index)
                
                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(activeColor)
                            .matchedGeometryEffect(id: "activeTab", in: animationNamespace)
                            .shadow(color: activeColor.opacity(0.3), radius: 4, x: 0, y: 2)
                    }
                    
                    Text(options[index])
                        .font(.system(size: 14, weight: isSelected ? .medium : .regular, design: .rounded))
                        .foregroundColor(isSelected ? .white : .blackText)
                        .padding(.vertical, 8)
                }
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selection = index
                    }
                }
            }
        }
        .padding(4)
        .background(backgroundColor)
        .cornerRadius(12)
    }
    
    @Namespace private var animationNamespace
}

