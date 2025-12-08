//
//  EnterNameStepView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 04.12.2025.
//

import SwiftUI

struct EnterNameStepView: View {
    let invitationCode: String
    
    // Состояния для этого экрана
    @State private var childName = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    @State private var isCompletedStepActive = false
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 25) {
            Text("Как зовут ребёнка?")
                .font(.system(size: 24, weight: .semibold, design: .rounded))
                .frame(maxWidth: .infinity, alignment: .center)
            
            TextField("Ваше имя", text: $childName)
                .padding(12)
                .background(Color.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.accent, lineWidth: 1)
                )

            if let error = errorMessage {
                ValidationErrorView(text: error)
            }
            
            Spacer()
            
            // --- Кнопка действия ---
            if isLoading {
                ProgressView("Подключение...")
            }
            
            NavigationLink(
                destination: ChildCompletedView(),
                isActive: $isCompletedStepActive
            ) { EmptyView() }
            
            ContinueButton(
                model: ContinueButtonModel(
                    title: "Продолжить",
                    isEnabled: invitationCode.count == 6,
                    action: {
                        Task {
                            await acceptInvitation()
                        }
                    }
                )
            )
            .frame(height: 50)
            // Проверить при следующей попытке регистрации ребенка и взрослого (вместо NavigationLink)
//            .navigationDestination(isPresented: $isCompletedStepActive) {
//                ChildCompletedView()
//            }
        }
        .padding(.top, 40)
        .padding(.bottom, 92)
        .padding(.horizontal, 20)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .ignoresSafeArea(.container, edges: .bottom)
        .ignoresSafeArea(.keyboard, edges: .bottom)
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
                            .foregroundColor(.accent)
                    }.frame(height: 50)
                }
            }
        }
    }
    
    private func acceptInvitation() async {
        isLoading = true; errorMessage = nil
        do {
            let parentID = try await CloudKitManager.shared.acceptInvitationByChild(withCode: invitationCode, childName: childName)
            print("✅ Успешно подключен к родителю \(parentID). Завершаю настройку.")
            isCompletedStepActive = true
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

