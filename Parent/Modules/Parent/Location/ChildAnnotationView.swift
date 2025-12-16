//
//  ChildAnnotationView.swift
//  Parent
//
//  Created by Michail Shagovitov on 16.12.2025.
//

import SwiftUI

struct ChildAnnotationView: View {
    let name: String
    let isSelected: Bool
    
    private var primaryColor: Color {
        isSelected ? .pin : Color(red: 0.2, green: 0.8, blue: 1.0)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Text(name)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(primaryColor)
                .foregroundColor(.white)
                .cornerRadius(6)
                .opacity(1.0)
            
            ZStack {
                Circle()
                    .fill(primaryColor.opacity(0.3))
                    .frame(width: 44, height: 44)
                
                Circle()
                    .fill(primaryColor)
                    .frame(width: 12, height: 12)
                    .overlay(Circle().stroke(Color.clear, lineWidth: 12))
            }
        }
        .offset(y: isSelected ? 0 : 20)
    }
}

