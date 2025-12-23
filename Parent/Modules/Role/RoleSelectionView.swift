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
            Text("Кто вы?")
                .font(.system(size: 24, weight: .medium, design: .rounded))
            
            VStack(spacing: 20) {
                RoleCardView(
                    model: RoleCardViewModel(
                        title: "Родитель",
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
                        title: "Ребёнок",
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
                        title: "Продолжить",
                        isEnabled: selectedRole != nil,
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
        
        stateManager.setRole(role)
        
        await stateManager.requestAuthorization()
        
        if role == .parent {
            stateManager.appState = .authRequired
        } else {
            stateManager.appState = .childPairing
        }
        isLoading = false
    }
}
