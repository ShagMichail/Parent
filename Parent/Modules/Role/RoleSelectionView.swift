//
//  RoleSelectionView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 10.11.2025.
//

import SwiftUI

struct RoleSelectionView: View {
    @EnvironmentObject var stateManager: AppStateManager
    @State private var selectedRole: UserRole? = nil
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 25) {
            Text("Who are you?")
                .font(.custom("Inter-Medium", size: 24))
            
            VStack(spacing: 20) {
                RoleCardView(
                    model: RoleCardViewModel(
                        title: String(localized: "Parent"),
                        imageName: "parents-art",
                        isSelected: selectedRole == .parent
                    )
                )
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedRole = .parent
                    }
                }
                
                RoleCardView(
                    model: RoleCardViewModel(
                        title: String(localized: "Child"),
                        imageName: "children-art",
                        isSelected: selectedRole == .child
                    )
                )
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedRole = .child
                    }
                }
            }
            
            Spacer()
            
            if isLoading {
                ProgressView()
                    .frame(height: 50)
            } else {
                ContinueButton(
                    model: ContinueButtonModel(
                        title: String(localized: "Continue"),
                        isEnabled: selectedRole != nil,
                        fullWidth: true,
                        action: {
                            Task {
                                await handleContinue()
                            }
                        }
                    )
                )
                .frame(height: 50)
            }
        }
        .padding(.bottom, 92)
        .padding(.top, 80)
        .padding(.horizontal, 20)
        .background(Color.roleBackground.ignoresSafeArea())
        .ignoresSafeArea(.container, edges: .bottom)
    }
    
    private func handleContinue() async {
        guard let role = selectedRole else { return }
        
        isLoading = true
        
        // 1. Устанавливаем роль (это нужно, чтобы `requestAuthorization` знала, что запрашивать)
        stateManager.setRole(role)
        
        // 2. ПОЛУЧАЕМ РЕЗУЛЬТАТ ЗАПРОСА
        let granted = await stateManager.requestAuthorization()
        
        // 3. ПРОВЕРЯЕМ РЕЗУЛЬТАТ
        if granted {
            if role == .parent {
                stateManager.appState = .authRequired
            } else {
                stateManager.appState = .childPairing
            }
        } else {
            print("ℹ️ Разрешение не получено, остаемся на экране выбора роли.")
            isLoading = false
        }
    }
}
