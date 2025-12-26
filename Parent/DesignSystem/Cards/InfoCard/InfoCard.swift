//
//  InfoCard.swift
//  Parent
//
//  Created by Михаил Шаговитов on 05.12.2025.
//

import SwiftUI

struct InfoCard: View {
    
    let model: InfoCardModel
    @Binding var isPinging: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(model.title)
                .font(.custom("Inter-Medium", size: 16))
                .foregroundColor(.blackText)
            
            HStack(spacing: 10) {
                Image(model.icon)
                    .frame(width: 16, height: 16)
                    .foregroundColor(.accent)
                Text(model.location)
                    .font(.custom("Inter-Regular", size: 16))
                    .foregroundColor(.blackText)
                
                Spacer()
                
                HStack(spacing: 10) {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(model.statusColor)
                            .frame(width: 8, height: 8)
                        Text(model.status)
                            .font(.custom("Inter-Regular", size: 16))
                            .foregroundColor(.blackText)
                    }
                    if isPinging {
                        ProgressView()
                            .frame(width: 24, height: 24)
                    } else {
                        Button(action: model.onRefresh) {
                            Image("refresh")
                                .frame(width: 24, height: 24)
                                .foregroundColor(.accent)
                        }
                    }
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 16)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.white)
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
}
