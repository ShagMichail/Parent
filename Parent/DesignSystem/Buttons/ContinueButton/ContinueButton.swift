//
//  ContinueButton.swift
//  Parent
//
//  Created by Михаил Шаговитов on 04.12.2025.
//

import SwiftUI

struct ContinueButton: View {
    let model: ContinueButtonModel
    
    var body: some View {
        Button(action: model.action) {
            Text(model.title)
                .font(.custom("Inter-Regular", size: 18))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(model.isEnabled ? Color.accent : Color.accent.opacity(0.5))
                )
        }
        .disabled(!model.isEnabled)
        .animation(.easeInOut, value: model.isEnabled)
    }
}
