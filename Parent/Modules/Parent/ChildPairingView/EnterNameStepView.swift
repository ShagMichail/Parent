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
    @State private var childAppleID = ""
    @State private var isLoading = false
    
    @State private var errorMessageName: String?
    @State private var isFailedName: Bool = false
    
    @State private var errorMessageAppleID: String?
    @State private var isFailedAppleID: Bool = false
    
    @State private var errorMessage: String?
    @State private var isFailed: Bool = false
    
    @State private var isCompletedStepActive = false
    
    @Environment(\.presentationMode) var presentationMode
    
    private let childNameStorageKey = "com.laborato.child.name"
    private let childGenderStorageKey = "com.laborato.child.gender"
    
    var body: some View {
        VStack(spacing: 25) {
            Text("What is the child's name?")
                .font(.custom("Inter-SemiBold", size: 24))
                .frame(maxWidth: .infinity, alignment: .center)
            
            VStack(spacing: 16) {
                TextField("Enter a name", text: $childName)
                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.accent, lineWidth: 1)
                    )
                    .onChange(of: childName) { _, _ in
                        if isFailedName {
                            isFailedName = false
                            errorMessageName = nil
                        }
                        if isFailed {
                            isFailed = false
                            errorMessage = nil
                        }
                    }
                
                if let error = errorMessageName, isFailedName {
                    ValidationErrorView(text: error)
                }
            }
            
            VStack(spacing: 16) {
                TextField("Enter the child's AppleID", text: $childAppleID)
                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.accent, lineWidth: 1)
                    )
                    .onChange(of: childAppleID) { _, _ in
                        if isFailedAppleID {
                            isFailedAppleID = false
                            errorMessageAppleID = nil
                        }
                        if isFailed {
                            isFailed = false
                            errorMessage = nil
                        }
                    }
                
                if let error = errorMessageAppleID, isFailedAppleID {
                    ValidationErrorView(text: error)
                }
            }
            
            if let error = errorMessage, isFailed {
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
                    fullWidth: true,
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
        let trimmedName = childName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedAppleID = childAppleID.trimmingCharacters(in: .whitespacesAndNewlines)

        // 1. Обновляем состояния одной строкой для каждого поля
        isFailedName = trimmedName.isEmpty
        errorMessageName = trimmedName.isEmpty ? String(localized: "Please enter your name") : nil

        isFailedAppleID = trimmedAppleID.isEmpty
        errorMessageAppleID = trimmedAppleID.isEmpty ? String(localized: "Please enter your Apple ID") : nil

        // 2. Проверяем: если хоть одно поле пустое — выходим
        guard !trimmedName.isEmpty, !trimmedAppleID.isEmpty else { return }
        
        isLoading = true
        
        
        do {
            // 1. Отправляем данные в CloudKit
            let parentID = try await CloudKitManager.shared.acceptInvitationByChild(
                withCode: invitationCode,
                childName: trimmedName,
                childGender: childGender,
                childAppleID: childAppleID
            )
            print("✅ Успешно подключен к родителю \(parentID). Завершаю настройку.")
            
            // 2. Сохраняем имя локально
            UserDefaults.standard.set(trimmedName, forKey: childNameStorageKey)
            if let defaults = UserDefaults(suiteName: "group.com.laborato.test.Parent") {
                defaults.set(trimmedName, forKey: "myChildName")
                defaults.set(childAppleID, forKey: "myChildAppleID")
            }
            print("💾 Имя ребенка '\(trimmedName)' сохранено в UserDefaults.")
            // 3. Сохраняем гендер локально
            UserDefaults.standard.set(childGender, forKey: childGenderStorageKey)
            print("💾 Гендер ребенка '\(childGender)' сохранено в UserDefaults.")
            
            // 4. Переходим на следующий экран
            isCompletedStepActive = true
            
        } catch {
            // 5. Обрабатываем ошибку
            isFailed = true
            errorMessage = error.localizedDescription
            print("❌ Ошибка при принятии приглашения: \(error.localizedDescription)")
        }
        
        // 6. Завершаем индикатор загрузки в любом случае
        isLoading = false
    }
}


#Preview {
    // Состояние: Темная тема
    EnterNameStepView(invitationCode: "123456", childGender: "girl")
        .environmentObject(AppStateManager(authService: AuthenticationService(), cloudKitManager: CloudKitManager()))
}
