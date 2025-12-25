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
    let onRefresh: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 10) {
                Text(child.name)
                    .font(.custom("Inter-Medium", size: 18))
                    .foregroundColor(.blackText)
                
                Text(address)
                    .font(.custom("Inter-Regular", size: 16))
                    .foregroundColor(.blackText)
                    .lineLimit(2)
            }
            
            Spacer()
            
            VStack(spacing: 10) {
                Text("Current location")
                    .font(.custom("Inter-Regular", size: 14))
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
