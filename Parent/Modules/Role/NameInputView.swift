//
//  NameInputView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 10.11.2025.
//

import SwiftUI

struct NameInputView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var familyManager: FamilyManager
    let selectedRole: MemberType
    
    @State private var userName = ""
    @State private var appleId = ""
    @State private var isLoading = false
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Основная информация")) {
                    TextField("Ваше имя", text: $userName)
                    TextField("Ваш Apple ID", text: $appleId)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                }
                
                Section(header: Text("Роль")) {
                    Text(selectedRole == .parent ? "Родитель" : "Ребенок")
                        .foregroundColor(.secondary)
                }
                
                if selectedRole == .parent {
                    Section(footer: Text("После регистрации вы настроите Family Sharing и добавите детские устройства через системные настройки")) {
                        // Информация для родителя
                    }
                }
            }
            .navigationTitle("Завершение регистрации")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                    .disabled(isLoading)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isLoading {
                        ProgressView()
                    } else {
                        Button("Готово") {
                            Task {
                                await createUser()
                            }
                        }
                        .disabled(!isFormValid)
                    }
                }
            }
            .alert("Ошибка", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private var isFormValid: Bool {
        return !userName.trimmingCharacters(in: .whitespaces).isEmpty &&
               !appleId.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    private func createUser() async {
        isLoading = true
        
        do {
            try await familyManager.createUser(
                name: userName.trimmingCharacters(in: .whitespaces),
                appleId: appleId.trimmingCharacters(in: .whitespaces),
                role: selectedRole
            )
            
            await MainActor.run {
                dismiss()
            }
            
        } catch {
            await MainActor.run {
                errorMessage = "Ошибка регистрации: \(error.localizedDescription)"
                showingError = true
                isLoading = false
            }
        }
    }
}
