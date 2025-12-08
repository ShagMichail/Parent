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
            
            ContinueButton(
                model: ContinueButtonModel(
                    title: "Продолжить",
                    isEnabled: selectedRole != nil,
                    action: {
                        guard let role = selectedRole else { return }
                        
                        if role == .parent {
                            Task {
                                stateManager.setRole(.parent)
                                await stateManager.requestAuthorization()
                            }
                        } else {
                            Task {
                                stateManager.setRole(.child)
                                await stateManager.requestAuthorization()
                            }
                        }
                    }
                )
            )
            .frame(height: 50)
        }
        .padding(.bottom, 92)
        .padding(.top, 80)
        .padding(.horizontal, 20)
        .background(Color.roleBackround.ignoresSafeArea())
        .ignoresSafeArea(.container, edges: .bottom)
    }
}
