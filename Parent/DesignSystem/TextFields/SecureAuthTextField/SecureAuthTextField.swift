//
//  SecureAuthTextField.swift
//  Parent
//
//  Created by Михаил Шаговитов on 03.12.2025.
//

import SwiftUI

//struct SecureAuthTextField: View {
//    let model: TextFieldModel
//    @Binding var text: String
//    @State private var isSecured = true
//    
//    @Binding var isLongEnough: Bool?
//    @Binding var hasCapitalAndDigit: Bool?
//    @Binding var showValidation: Bool?
//    @Binding var passwordsMatch: Bool?
//    
//    // Инициализатор для обычного поля (без валидации)
//    init(model: TextFieldModel, text: Binding<String>) {
//        self.model = model
//        self._text = text
//        self._isLongEnough = .constant(nil)
//        self._hasCapitalAndDigit = .constant(nil)
//        self._passwordsMatch = .constant(nil)
//        self._showValidation = .constant(nil)
//    }
//
//    // Инициализатор для поля с валидацией
//    init(model: TextFieldModel, text: Binding<String>, isLongEnough: Binding<Bool?>, hasCapitalAndDigit: Binding<Bool?>, showValidation: Binding<Bool?>) {
//        self.model = model
//        self._text = text
//        self._isLongEnough = isLongEnough
//        self._hasCapitalAndDigit = hasCapitalAndDigit
//        self._passwordsMatch = .constant(nil)
//        self._showValidation = showValidation
//    }
//    
//    init(model: TextFieldModel, text: Binding<String>, passwordsMatch: Binding<Bool?>, showValidation: Binding<Bool?>) {
//        self.model = model
//        self._text = text
//        self._isLongEnough = .constant(nil)
//        self._hasCapitalAndDigit = .constant(nil)
//        self._passwordsMatch = passwordsMatch
//        self._showValidation = showValidation
//    }
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            Text(model.title)
//                .font(.system(size: 12, weight: .regular, design: .rounded))
//                .foregroundColor(Color.blackText)
//
//            ZStack(alignment: .trailing) {
//                if isSecured {
//                    SecureField(model.placeholder, text: $text)
//                        .padding(12)
//                        .padding(.trailing, 40)
//                } else {
//                    TextField(model.placeholder, text: $text)
//                        .padding(12)
//                        .padding(.trailing, 40)
//                }
//                
//                Button(action: { isSecured.toggle() }) {
//                    Image(systemName: isSecured ? "eye.slash" : "eye")
//                        .foregroundColor(Color.strokeTextField)
//                }
//                .padding(.trailing, 12)
//            }
//            .background(Color.white)
//            .cornerRadius(12)
//            .overlay(
//                RoundedRectangle(cornerRadius: 12)
//                    .stroke(Color.strokeTextField, lineWidth: 1)
//            )
//            
//            if showValidation == true {
//                VStack(alignment: .leading, spacing: 8) {
//                    if !(isLongEnough ?? true) {
//                        Text("*Пароль должен быть не короче 8 символов")
//                            .font(.system(size: 12, weight: .regular, design: .rounded))
//                            .foregroundColor(Color.errorMessage)
//                            .fixedSize(horizontal: false, vertical: true)
//                    }
//                    if !(hasCapitalAndDigit ?? true) {
//                        Text("*Пароль должен содержать хотя бы одну заглавную букву и одну цифру")
//                            .font(.system(size: 12, weight: .regular, design: .rounded))
//                            .foregroundColor(Color.errorMessage)
//                            .fixedSize(horizontal: false, vertical: true)
//                    }
//                }
//                
//                if let passwordsMatch = passwordsMatch, !passwordsMatch {
//                    Text("*Пароли должны совпадать")
//                        .font(.system(size: 12, weight: .regular, design: .rounded))
//                        .foregroundColor(Color.errorMessage)
//                        .fixedSize(horizontal: false, vertical: true)
//                }
//            }
//        }
//    }
//}

struct SecureAuthTextField: View {
    let title: String
    let placeholder: String
    
    // Принимаем ViewModel как ObservedObject
    @ObservedObject var viewModel: AuthViewModel
    
    // Binding к конкретному полю в модели `credentials`
    @Binding var text: String
    
    // Определяем, для какого поля мы показываем валидацию
    let validationField: ValidationField
    
    @State private var isSecured = true
    
    // Enum для определения типа поля
    enum ValidationField {
        case password // Первое поле пароля
        case confirmPassword // Второе поле пароля
        case none // Без валидации
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 12, weight: .regular, design: .rounded))
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
            
            // --- НОВАЯ, УМНАЯ ЛОГИКА ОТОБРАЖЕНИЯ ОШИБОК ---
            if viewModel.showValidationErrors {
                // Ошибки для первого поля
                if validationField == .password {
                    if !viewModel.passwordValidation.isLongEnough {
                        ValidationErrorView(text: "Пароль должен быть не короче 8 символов")
                    }
                    if !viewModel.passwordValidation.hasCapitalAndDigit {
                        ValidationErrorView(text: "Пароль должен содержать хотя бы одну заглавную букву и одну цифру")
                    }
                }
                
                // Ошибка для второго поля
                if validationField == .confirmPassword && !text.isEmpty && !viewModel.passwordValidation.passwordsMatch {
                    ValidationErrorView(text: "Пароли должны совпадать")
                }
            }
        }
        .animation(.spring(response: 0.2, dampingFraction: 0.8), value: viewModel.showValidationErrors)
    }
    
    /// Вычисляемое свойство для определения цвета рамки
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
