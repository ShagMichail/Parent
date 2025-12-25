//
//  SecureAuthTextField.swift
//  Parent
//
//  Created by Михаил Шаговитов on 03.12.2025.
//

import SwiftUI

struct SecureAuthTextField: View {
    @ObservedObject var viewModel: AuthViewModel

    @Binding var text: String
    
    @State private var isSecured = true
    
    enum ValidationField {
        case password
        case confirmPassword
        case none
    }
    
    let title: String
    let placeholder: String
    let validationField: ValidationField
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.custom("Inter-Regular", size: 12))
                .foregroundColor(Color.blackText)

            ZStack(alignment: .trailing) {
                if isSecured {
                    SecureField(placeholder, text: $text)
                        .padding(12)
                        .padding(.trailing, 40)
                } else {
                    TextField(placeholder, text: $text)
                        .padding(12)
                        .padding(.trailing, 40)
                }
                
                Button(action: { isSecured.toggle() }) {
                    Image(systemName: isSecured ? "eye.slash" : "eye")
                        .foregroundColor(Color.strokeTextField)
                }
                .padding(.trailing, 12)
            }
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: 1)
            )
            
            if viewModel.showValidationErrors {
                if validationField == .password {
                    if !viewModel.passwordValidation.isLongEnough {
                        ValidationErrorView(text: String(localized: "Password must be no shorter than 8 characters"))
                    }
                    if !viewModel.passwordValidation.hasCapitalAndDigit {
                        ValidationErrorView(text: String(localized: "Password must contain at least one capital letter and one number"))
                    }
                }
                
                if validationField == .confirmPassword && !text.isEmpty && !viewModel.passwordValidation.passwordsMatch {
                    ValidationErrorView(text: String(localized: "Passwords must match"))
                }
            }
        }
        .animation(.spring(response: 0.2, dampingFraction: 0.8), value: viewModel.showValidationErrors)
    }
    
    private var borderColor: Color {
        guard viewModel.showValidationErrors, !text.isEmpty else { return Color.strokeTextField }
        
        if validationField == .password {
            return viewModel.passwordValidation.isPasswordValid ? .green : .red
        }
        if validationField == .confirmPassword {
            return viewModel.passwordValidation.passwordsMatch ? .green : .red
        }
        return Color.strokeTextField
    }
}
