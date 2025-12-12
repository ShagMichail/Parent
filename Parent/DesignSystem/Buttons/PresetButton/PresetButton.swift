//
//  PresetButton.swift
//  Parent
//
//  Created by Michail Shagovitov on 10.12.2025.
//

import SwiftUI

// Компонент PresetButton
struct PresetButton: View {
    let title: String
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(isActive ? .accent : Color.gray.opacity(0.1))
                .foregroundColor(isActive ? .white : .blackText)
                .cornerRadius(8)
        }
    }
}
