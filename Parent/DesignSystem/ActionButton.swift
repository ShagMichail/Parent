//
//  ActionButton.swift
//  Parent
//
//  Created by Михаил Шаговитов on 02.12.2025.
//

import SwiftUI

struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 80, height: 80)
            .background(color)
            .cornerRadius(12)
        }
    }
}
