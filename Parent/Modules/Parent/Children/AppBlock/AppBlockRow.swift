//
//  AppBlockRow.swift
//  Parent
//
//  Created by Michail Shagovitov on 22.12.2025.
//

import SwiftUI

struct AppBlockRow: View {
    @Binding var block: AppBlock
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Label(block.token)
            }
            
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

