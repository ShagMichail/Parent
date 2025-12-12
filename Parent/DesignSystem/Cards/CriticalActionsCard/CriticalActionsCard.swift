//
//  CriticalActionsCard.swift
//  Parent
//
//  Created by Michail Shagovitov on 11.12.2025.
//

import SwiftUI

struct CriticalActionsCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.circle")
                    .foregroundColor(.red)
                    .font(.system(size: 20))
                
                Text("Критические действия")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.red)
            }
            
            Text("Никаких действий нет")
                .font(.system(size: 15))
                .foregroundColor(.green)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
    }
}
