//
//  AuthViewModel.swift
//  Parent
//
//  Created by Михаил Шаговитов on 03.12.2025.
//

import Foundation
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var serverError: String?
    @Published var showValidationErrors = false
    @Published var credentials = AuthCredentials()
    
    @Published private(set) var emailValidation = FieldValidationState()
    @Published private(set) var passwordValidation = PasswordValidationState()
    @Published private(set) var isFormValid = false
    
    private let mode: AuthMode
    private var cancellables = Set<AnyCancellable>()
    
    init(mode: AuthMode) {
        self.mode = mode
        setupValidationSubscribers()
    }
    
    // MARK: - Public Methods

    func submit(authService: AuthenticationService, stateManager: AppStateManager) {
        showValidationErrors = true
        guard isFormValid else { return }
        
        Task {
            // Обновление UI всегда на главном потоке
            await MainActor.run {
                isLoading = true
                serverError = nil
            }
            
//            do {
                let token: String
                
                // 1. Выполняем запрос к API (раскомментируй свои вызовы)
                if mode == .register {
                    // token = try await APIManager.shared.register(email: credentials.email, password: credentials.password)
                    token = "fake_token_for_test" // Временная заглушка
                } else {
                    // token = try await APIManager.shared.login(email: credentials.email, password: credentials.password)
                    token = "fake_token_for_test" // Временная заглушка
                }
                
                await MainActor.run {
                    authService.login(token: token)
                }
                
                await stateManager.initializeApp()
//                stateManager.parentDidAuthenticate()
//            } catch {
//                await MainActor.run {
//                    serverError = error.localizedDescription
//                }
//            }
            
            await MainActor.run {
                isLoading = false
            }
        }
    }
    
    // MARK: - Private Validation Logic
    private func setupValidationSubscribers() {
        
        $credentials
            .map(\.email)
            .sink { [weak self] email in
                if email.isEmpty {
                    self?.emailValidation = FieldValidationState(isValid: false, error: String(localized: "The Mail field cannot be empty"))
                }
                // В будущем можно добавить проверку формата
                // else if !email.isValidEmailFormat() {
                //     self?.emailValidation = FieldValidationState(isValid: false, error: "Неверный формат E-mail")
                // }
                else {
                    self?.emailValidation = FieldValidationState(isValid: true, error: nil)
                }
            }
            .store(in: &cancellables)
        
        $credentials
            .map(\.password)
            .sink { [weak self] password in
                guard let self = self else { return }
                self.passwordValidation.isLongEnough = password.count >= 8
                
                let hasCapital = password.rangeOfCharacter(from: .uppercaseLetters) != nil
                let hasDigit = password.rangeOfCharacter(from: .decimalDigits) != nil
                self.passwordValidation.hasCapitalAndDigit = hasCapital && hasDigit
            }
            .store(in: &cancellables)
        
        $credentials
            .map { ($0.password, $0.confirmPassword) }
            .sink { [weak self] (password, confirm) in
                // Поле совпадения валидно, только если оно не пустое и совпадает
                self?.passwordValidation.passwordsMatch = !confirm.isEmpty && password == confirm
            }
            .store(in: &cancellables)
        
        Publishers.CombineLatest($emailValidation, $passwordValidation)
            .map { [weak self] (emailValidation, passwordValidation) -> Bool in
                guard let self = self else { return false }
                
                if self.mode == .register {
                    return emailValidation.isValid && passwordValidation.isPasswordSectionValid
                } else {
                    return emailValidation.isValid && !self.credentials.password.isEmpty
                }
            }
            .assign(to: \.isFormValid, on: self)
            .store(in: &cancellables)
    }
    
    // --- Функция валидации Email ---
    //    private func validateEmail(_ email: String) {
    //        // Просто проверяем на пустоту. В будущем можно добавить проверку формата.
    //        validationState.isEmailValid = !email.isEmpty
    //    }
}
