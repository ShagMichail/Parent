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
        // --- Проверка на пустое имя ---
        let trimmedName = childName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            errorMessage = "Пожалуйста, введите ваше имя."
            return
        }
        
        // --- Начало асинхронной операции ---
        isLoading = true
        errorMessage = nil
        
        do {
            // 1. Отправляем данные в CloudKit
            let parentID = try await CloudKitManager.shared.acceptInvitationByChild(
                withCode: invitationCode,
                childName: trimmedName, // Используем очищенное имя
                childGender: childGender
            )
            print("✅ Успешно подключен к родителю \(parentID). Завершаю настройку.")
            
            // 2. ✅ ГЛАВНОЕ ИЗМЕНЕНИЕ: Сохраняем имя локально
            // Мы делаем это только после того, как `acceptInvitationByChild`
            // выполнился без ошибок, чтобы не сохранять имя в случае сбоя.
            UserDefaults.standard.set(trimmedName, forKey: childNameStorageKey)
            print("💾 Имя ребенка '\(trimmedName)' сохранено в UserDefaults.")
            
            UserDefaults.standard.set(childGender, forKey: childGenderStorageKey)
            print("💾 Имя ребенка '\(childGender)' сохранено в UserDefaults.")
            
            // 3. Переходим на следующий экран
            isCompletedStepActive = true
            
        } catch {
            // 4. Обрабатываем ошибку
            errorMessage = error.localizedDescription
            print("❌ Ошибка при принятии приглашения: \(error.localizedDescription)")
        }
        
        // 5. Завершаем индикатор загрузки в любом случае
        isLoading = false
    }
}

