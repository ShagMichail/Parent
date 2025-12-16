//
//  AuthFormView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 03.12.2025.
//

import SwiftUI

struct AuthFormView: View {
    
    let mode: AuthMode
    @StateObject private var viewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var stateManager: AppStateManager
    @EnvironmentObject var authService: AuthenticationService
    
    init(mode: AuthMode) {
        self.mode = mode
        self._viewModel = StateObject(wrappedValue: AuthViewModel(mode: mode))
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.accent, Color.accent]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                headerView
                formView
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
        .navigationBarBackButtonHidden(true)
        .toolbarRole(.editor)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.backward")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var headerView: some View {
        VStack(spacing: 20) {
            Image("lock")
                .frame(width: 120, height: 120)
            
            Text(mode == .register ? "Регистрация\nвашего аккаунта" : "Вход в ваш аккаунт")
                .font(.system(size: 36, weight: .medium, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
        .padding(.top, 35)
        .padding(.bottom, 20)
    }
    
    @ViewBuilder
    private var formView: some View {
        VStack(spacing: 24) {
            AuthTextField(
                model: .init(title: "Почта", placeholder: "Введите почту"),
                text: $viewModel.credentials.email,
                viewModel: viewModel
            )
            .keyboardType(.emailAddress)
            .textContentType(.emailAddress)
            .autocapitalization(.none)
            .padding(.top, 35)
            
            SecureAuthTextField(
                viewModel: viewModel,
                text: $viewModel.credentials.password,
                title: "Пароль",
                placeholder: mode == .register ? "Придумайте пароль" : "Введите пароль",
                validationField: (mode == .register) ? .password : .none
            )
            
            if mode == .register {
                SecureAuthTextField(
                    viewModel: viewModel,
                    text: $viewModel.credentials.confirmPassword,
                    title: "Повторите пароль",
                    placeholder: "Повторите пароль",
                    validationField: .confirmPassword
                )
            }
            
            Spacer()
            
            Button(action: {
                viewModel.submit(authService: authService, stateManager: stateManager)
            }) {
                MainButton(model:
                            MainButtonModel(
                                title: mode == .register ? "Зарегистрироваться" : "Авторизоваться",
                                font: .system(size: 18, weight: .regular, design: .rounded),
                                foregroundColor: .white,
                                cornerRadius: 12,
                                background: Color.accent,
                                strokeColor: Color.accent,
                                strokeLineWidth: 0
                            )
                )
                .frame(height: 50)
            }
            .padding(.bottom, 96)
            .disabled(viewModel.isLoading)
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .clipShape(RoundedCorner(radius: 30, corners: [.topLeft, .topRight]))
        .ignoresSafeArea(.container, edges: .bottom)
    }
}
