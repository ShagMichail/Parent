//
//  AuthView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 03.12.2025.
//

import SwiftUI

struct AuthView: View {
    @EnvironmentObject var stateManager: AppStateManager
    @EnvironmentObject var authService: AuthenticationService

    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    Image("family-background")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: UIScreen.main.bounds.height * 0.8)
                        .clipped()
                    
                    Spacer()
                }
                .edgesIgnoringSafeArea(.all)
                
                VStack {
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.black.opacity(0.3),
                            Color.white.opacity(0.6),
                            Color.white.opacity(1.0)
                        ]),
                        startPoint: .center,
                        endPoint: .bottom
                    )
                    .frame(height: UIScreen.main.bounds.height * 0.8)
                    .clipped()
                    
                    Spacer()
                }
                .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Spacer()
                    
                    Image("lock")
                        .frame(width: 120, height: 120)
                        .padding(.bottom, 30)
                    
                    Text("Добро пожаловать!")
                        .font(.custom("Inter-Medium", size: 34))
                        .foregroundColor(.accent)
                        .padding(.bottom, 30)
                    
                    Text("Цифровая безопасность вашей семьи\nначинается здесь.")
                        .font(.custom("Inter-Regular", size: 16))
                        .foregroundColor(Color.accent)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.bottom, 40)
                    // Кнопки
                    VStack(spacing: 16) {
                        
                        NavigationLink(destination: AuthContainerView(initialMode: .register)) {
                            MainButton(model:
                                        MainButtonModel(
                                            title: "Зарегистрироваться",
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
                        
                        NavigationLink(destination: AuthContainerView(initialMode: .login)) {
                            MainButton(model:
                                        MainButtonModel(
                                            title: "Авторизоваться",
                                            font: .custom("Inter-Regular", size: 18),
                                            foregroundColor: Color.accent,
                                            cornerRadius: 12,
                                            background: Color.white,
                                            strokeColor: Color.accent,
                                            strokeLineWidth: 2
                                        )
                            )
                            .frame(height: 50)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
                .padding(.top)
            }
            .background(Color.white.edgesIgnoringSafeArea(.all))
            .ignoresSafeArea(.container, edges: .bottom)
        }
    }
}
