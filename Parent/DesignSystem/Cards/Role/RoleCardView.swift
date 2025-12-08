//
//  RoleCardView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 04.12.2025.
//

import SwiftUI

struct RoleCardView: View {
    let model: RoleCardViewModel
    
    var body: some View {
        VStack(spacing: 10) {
            Text(model.title)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.black)
            
            Image(model.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 160)
                .clipShape(RoundedCorner(radius: 70, corners: [.topLeft, .topRight]))
        }
        .padding(.top, 25)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(model.isSelected ? Color.accent : Color.clear, lineWidth: 2.5)
        )
        .shadow(
            color: model.isSelected ? Color.accent.opacity(0.2) : Color.black.opacity(0.08),
            radius: 8,
            x: 0,
            y: 4
        )
    }
}
