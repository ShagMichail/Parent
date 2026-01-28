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
                .foregroundColor(model.textColor)
                .frame(maxWidth: model.fullWidth ? .infinity : nil)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(model.isBackground ? (model.isEnabled ? Color.accent : Color.accent.opacity(0.5)) : Color.clear)
                )
        }
        .disabled(!model.isEnabled)
        .animation(.easeInOut, value: model.isEnabled)
    }
}

#Preview {
    VStack(spacing: 20) {
        ContinueButton(
            model: ContinueButtonModel(
                title: String(localized: "or scan the code"),
                isEnabled: true,
                fullWidth: true,
                action: { }
            )
        )
        .frame(height: 50)

        ContinueButton(
            model: ContinueButtonModel(
                title: String(localized: "Update the code"),
                isEnabled: true,
                isBackground: false,
                textColor: .accent,
                action: { }
            )
        )
        .frame(height: 50)
    }
}
