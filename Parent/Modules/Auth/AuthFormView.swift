//
//  AuthFormView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 03.12.2025.
//

import SwiftUI

struct AuthFormView: View {
    
    @Binding var mode: AuthMode
    @StateObject private var viewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var stateManager: AppStateManager
    @EnvironmentObject var authService: AuthenticationService
    
    init(mode: Binding<AuthMode>) {
        self._mode = mode
        self._viewModel = StateObject(wrappedValue: AuthViewModel(mode: mode.wrappedValue))
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
                headerView(mode: viewModel.mode)
                formView(mode: viewModel.mode)
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
        .navigationBarBackButtonHidden(true)
    }
    
    @ViewBuilder
    private func headerView(mode: AuthMode) -> some View {
        VStack(spacing: 20) {
            Image("logocontrol")
                .resizable()
                .frame(width: 120, height: 120)
            
            Text(mode == .register ? "Registering your account" : "Login to your account")
                .font(.custom("Inter-Medium", size: 36))
                .foregroundColor(.white)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
        .padding(.top, 35)
        .padding(.bottom, 20)
    }
    
    @ViewBuilder
    private func formView(mode: AuthMode) -> some View {
        VStack(spacing: 24) {
            AuthTextField(
                model: .init(title: String(localized: "Mail"), placeholder: String(localized: "Enter your email")),
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
                title: String(localized: "Password"),
                placeholder: mode == .register ? String(localized: "Create a password") : String(localized: "Enter your password"),
                validationField: (mode == .register) ? .password : .none
            )
            
            if mode == .register {
                SecureAuthTextField(
                    viewModel: viewModel,
                    text: $viewModel.credentials.confirmPassword,
                    title: String(localized: "Repeat password"),
                    placeholder: String(localized: "Repeat password"),
                    validationField: .confirmPassword
                )
            }
            
            Spacer()
            
            VStack(spacing: 30) {
                
                Button(action: {
                    viewModel.submit(authService: authService, stateManager: stateManager)
                }) {
                    MainButton(model:
                                MainButtonModel(
                                    title: mode == .register ? String(localized: "Register") : String(localized: "Login"),
                                    font: .custom("Inter-Regular", size: 18),
                                    foregroundColor: .white,
                                    cornerRadius: 12,
                                    background: Color.accent,
                                    strokeColor: Color.accent,
                                    strokeLineWidth: 0
                                )
                    )
                    .frame(height: 50)
                }
                .disabled(viewModel.isLoading)
                
                HStack {
                    Text(mode == .register ? "Do you have an account?" : "No account?")
                        .font(.custom("Inter-Regular", size: 16))
                        .foregroundColor(.strokeTextField)
                    
                    Button(action: {
                        withAnimation {
                            viewModel.mode = (viewModel.mode == .login) ? .register : .login
                        }
                    }) {
                        Text(mode == .register ? "Login" : "Register")
                            .font(.custom("Inter-Regular", size: 16))
                            .foregroundColor(.accent)
                    }
                }
            }
            .padding(.bottom, 20)
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .clipShape(RoundedCorner(radius: 30, corners: [.topLeft, .topRight]))
        .ignoresSafeArea(.container, edges: .bottom)
    }
}
