//
//  AddChildView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 26.11.2025.
//

import SwiftUI

struct AddChildView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var stateManager: AuthenticationManager // 1. Получаем доступ к менеджеру
    
    @State private var childName = ""
    @State private var invitationCode = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        Form {
            Section(header: Text("Данные ребенка")) {
                TextField("Имя ребенка", text: $childName)
                TextField("Код приглашения", text: $invitationCode)
                    .keyboardType(.numberPad)
            }
            
            Section {
                if isLoading {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                } else {
                    Button("Добавить ребенка") {
                        Task {
                            await addChild()
                        }
                    }
                    .disabled(childName.isEmpty || invitationCode.count != 6)
                }
            }
            
            if let error = errorMessage {
                Section {
                    Text(error)
                        .foregroundColor(.red)
                }
            }
        }
        .navigationTitle("Добавить ребенка")
        .navigationBarTitleDisplayMode(.inline) // Делаем заголовок компактным
    }
    
    private func addChild() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // --- ШАГ 1: НАЙТИ ПРИГЛАШЕНИЕ ---
            // Вызываем нашу новую функцию поиска
            let (childID, recordToUpdate) = try await CloudKitManager.shared.acceptInvitation(withCode: invitationCode)
            
            // --- ШАГ 2: ОБНОВИТЬ НАЙДЕННУЮ ЗАПИСЬ ("ПОСТАВИТЬ ФЛАЖОК") ---
            // Получаем ID родителя
            guard let parentID = await CloudKitManager.shared.fetchUserRecordID() else {
                throw NSError(domain: "AddChildView", code: -1, userInfo: [NSLocalizedDescriptionKey: "Не удалось получить ID родителя"])
            }
            
            // Ставим "флажок", записывая ID родителя в поле.
            // Это действие вызовет push-уведомление на устройстве ребенка.
            recordToUpdate["acceptedByParentID"] = parentID
            
            // Сохраняем измененную запись
            try await CloudKitManager.shared.publicDatabase.save(recordToUpdate)
            
            // --- ШАГ 3: СОХРАНИТЬ РЕБЕНКА ЛОКАЛЬНО ---
            // Теперь, когда все успешно, сохраняем ребенка
            stateManager.addChild(name: childName, recordID: childID)
            dismiss() // Закрываем экран
            
        } catch {
            errorMessage = error.localizedDescription
            print("🚨 Ошибка в процессе принятия приглашения: \(error)")
        }
        
        isLoading = false
    }
}
