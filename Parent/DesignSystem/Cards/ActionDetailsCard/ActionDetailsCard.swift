//
//  ActionDetailsCard.swift
//  Parent
//
//  Created by Michail Shagovitov on 11.12.2025.
//

import SwiftUI

struct ActionDetailsCard: View {
    let category: ActionCategory
    
    // Сюда можно будет передать реальный массив данных
    // let actions: [ActionModel]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 10) {
                Image(category.icon)
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(category.startColor)
                
                Text(category.rawValue)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(category.startColor)
                
                Spacer()
            }
            
            HStack {
                Text(category.emptyStateText)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.gray)
                
                Spacer()
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
        )
        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
    }
}

