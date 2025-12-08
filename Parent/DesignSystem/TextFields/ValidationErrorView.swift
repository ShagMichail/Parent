//
//  ValidationErrorView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 04.12.2025.
//

import SwiftUI

struct ValidationErrorView: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "exclamationmark.circle")
            Text(text)
        }
        .font(.system(size: 12, weight: .regular, design: .rounded))
        .foregroundColor(Color.errorMessage)
        .fixedSize(horizontal: false, vertical: true)
        .transition(.opacity.combined(with: .move(edge: .top)))
    }
}
