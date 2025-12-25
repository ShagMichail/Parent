//
//  EnterNameStepView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 04.12.2025.
//

import SwiftUI

struct EnterNameStepView: View {
    let invitationCode: String
    let childGender: String
    // Состояния для этого экрана
    @State private var childName = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    @State private var isCompletedStepActive = false
    
    @Environment(\.presentationMode) var presentationMode
    
    private let childNameStorageKey = "com.laborato.child.name"
    private let childGenderStorageKey = "com.laborato.child.gender"
    
    var body: some View {
        VStack(spacing: 25) {
            Text("What is the child's name?")
                .font(.custom("Inter-SemiBold", size: 24))
                .frame(maxWidth: .infinity, alignment: .center)
            
            TextField("Enter a name", text: $childName)
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
                ProgressView("Connection...")
            }

            ContinueButton(
                model: ContinueButtonModel(
                    title: String(localized: "Continue"),
                    isEnabled: invitationCode.count == 6,
                    action: {
                        Task {
                            await acceptInvitation()
                        }
                    }
                )
            )
            .frame(height: 50)
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
        .navigationDestination(isPresented: $isCompletedStepActive, destination: { ChildCompletedView() })
    }
    
    private func acceptInvitation() async {
        // --- Проверка на пустое имя ---
        let trimmedName = childName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            errorMessage = String(localized: "Please enter your name.")
            return
        }
        
        // --- Начало асинхронной операции ---
        isLoading = true
        errorMessage = nil
        
        do {
            // 1. Отправляем данные в CloudKit
            let parentID = try await CloudKitManager.shared.acceptInvitationByChild(
                withCode: invitationCode,
                childName: trimmedName,
                childGender: childGender
            )
            print("✅ Успешно подключен к родителю \(parentID). Завершаю настройку.")
            
            // 2. Сохраняем имя локально
            UserDefaults.standard.set(trimmedName, forKey: childNameStorageKey)
            print("💾 Имя ребенка '\(trimmedName)' сохранено в UserDefaults.")
            // 3. Сохраняем гендер локально
            UserDefaults.standard.set(childGender, forKey: childGenderStorageKey)
            print("💾 Гендер ребенка '\(childGender)' сохранено в UserDefaults.")
            
            // 4. Переходим на следующий экран
            isCompletedStepActive = true
            
        } catch {
            // 5. Обрабатываем ошибку
            errorMessage = error.localizedDescription
            print("❌ Ошибка при принятии приглашения: \(error.localizedDescription)")
        }
        
        // 6. Завершаем индикатор загрузки в любом случае
        isLoading = false
    }
}

