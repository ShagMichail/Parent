//
//  AuthTextField.swift
//  Parent
//
//  Created by Михаил Шаговитов on 03.12.2025.
//

import SwiftUI

struct AuthTextField: View {
    let model: TextFieldModel
    @Binding var text: String
    
    @ObservedObject var viewModel: AuthViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(model.title)
                .font(.system(size: 12, weight: .regular, design: .rounded))
                .foregroundColor(Color.blackText)
            
            TextField(model.placeholder, text: $text)
                .padding(12)
                .background(Color.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(borderColor, lineWidth: 1)
                )
            
            if viewModel.showValidationErrors, let error = viewModel.emailValidation.error {
                ValidationErrorView(text: error)
            }
        }
    }
    
    /// Вычисляемое свойство для определения цвета рамки
    private var borderColor: Color {
        guard viewModel.showValidationErrors else { return Color.strokeTextField }
        return text.isEmpty ? .red : (viewModel.emailValidation.isValid ? .green : .red)
    }
}
