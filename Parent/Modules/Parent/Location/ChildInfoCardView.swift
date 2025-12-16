//
//  ChildInfoCardView.swift
//  Parent
//
//  Created by Michail Shagovitov on 16.12.2025.
//

import SwiftUI

struct ChildInfoCardView: View {
    @Binding var isPinging: Bool
    
    let child: Child
    let address: String
    let onRefresh: () -> Void // Замыкание для кнопки обновления
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 10) {
                Text(child.name)
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.blackText)
                
                Text(address)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(.blackText)
                    .lineLimit(2)
            }
            
            Spacer()
            
            VStack(spacing: 10) {
                Text("Текущее место")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(.strokeTextField)
                
                if isPinging {
                    ProgressView()
                        .frame(width: 24, height: 24)
                } else {
                    Button(action: onRefresh) {
                        Image("refresh")
                            .frame(width: 24, height: 24)
                            .foregroundColor(.accent)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background(.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
    }
}
