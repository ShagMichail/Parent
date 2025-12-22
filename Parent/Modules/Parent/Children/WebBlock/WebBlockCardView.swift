//
//  WebBlockCardView.swift
//  Parent
//
//  Created by Michail Shagovitov on 22.12.2025.
//

import SwiftUI

struct WebBlockCardView: View {
    let block: WebBlock
    
    var body: some View {
        HStack {
            // Можно добавить иконку, например "globe"
            Image(systemName: "globe")
                .font(.title2)
                .foregroundColor(.accentColor)
            
            Text(block.domain)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundStyle(.blackText)
            
            
            Spacer()
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 10)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.white)
            }
        )
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .contentShape(Rectangle())
    }
}
