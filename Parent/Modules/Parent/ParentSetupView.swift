//
//  ParentSetupView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 13.11.2025.
//

import SwiftUI

struct ParentSetupView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "shield.parental")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text("Настройка родительского контроля")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("Нажмите кнопку ниже, чтобы выбрать детей из вашей семейной группы, для которых вы хотите установить ограничения.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Button("Начать настройку") {
                authManager.requestParentAuthorization()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding(30)
    }
}

struct ChildSetupView: View {
    @EnvironmentObject var stateManager: AuthenticationManager
    @State private var invitationCode: String?
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 30) {
            if isLoading {
                ProgressView()
            } else if let code = invitationCode {
                Text("Покажите этот код родителю:")
                    .font(.title2)
                Text(code)
                    .font(.system(size: 50, weight: .bold, design: .monospaced))
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                Text("Этот код действителен в течение нескольких минут.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Text("Настройка устройства ребенка") // ... ваш UI
                Button("Сгенерировать код приглашения") {
                    isLoading = true
                    Task {
                        do {
                            self.invitationCode = try await CloudKitManager.shared.createInvitation()
                        } catch {
                            print("🚨 Ошибка создания приглашения: \(error)")
                        }
                        isLoading = false
                    }
                }
            }
        }
    }
}

struct AddChildView: View {
    @Environment(\.dismiss) var dismiss
    @State private var invitationCode = ""
    @State private var isLoading = false
    
    var onChildAdded: (String, String) -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Введите код с устройства ребенка")
                TextField("123456", text: $invitationCode)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                
                if isLoading {
                    ProgressView()
                }
                
                Button("Добавить ребенка") {
                    isLoading = true
                    Task {
                        do {
                            let childID = try await CloudKitManager.shared.acceptInvitation(withCode: invitationCode)
                            onChildAdded("Ivan", childID)
                            dismiss()
                        } catch {
                            print("🚨 Ошибка принятия приглашения: \(error)")
                        }
                        isLoading = false
                    }
                }
                .disabled(invitationCode.count != 6)
            }
            .navigationTitle("Добавить ребенка")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
            }
        }
    }
}
