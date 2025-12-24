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
        VStack {
            Text(model.title)
                .font(.custom("Inter-Medium", size: 16))
                .foregroundColor(.black)
            Spacer()
            
            Image(model.imageName)
                .aspectRatio(contentMode: .fit)
        }
        .padding(.top, 25)
        .frame(maxWidth: .infinity, maxHeight: 180)
        .background(Color.white)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(model.isSelected ? Color.accent : Color.clear, lineWidth: 2.5)
        )
        .shadow(
            color: model.isSelected ? Color.accent.opacity(0.2) : Color.black.opacity(0),
            radius: 8,
            x: 0,
            y: 5
        )
    }
}
