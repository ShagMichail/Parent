//
//  SettingsView.swift
//  Parent
//
//  Created by Michail Shagovitov on 13.01.2026.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @State private var showConfirmationAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                // ... Здесь могут быть ваши обычные настройки (Профиль, Уведомления и т.д.) ...
                
                Section(header: Text("Обычные настройки")) {
                    Text("Версия приложения: 1.0.0")
                    // ...
                }
                
                
                // --- ✅ СЕКЦИЯ ТОЛЬКО ДЛЯ РАЗРАБОТКИ ---
                
                #if DEBUG // Этот код будет включен только в Debug-сборках
                Section(header: Text("Инструменты разработчика (DEBUG ONLY)")) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Опасно! Эта кнопка удалит ВСЕ подписки CloudKit для текущего пользователя iCloud.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        // Кнопка для запуска удаления
                        Button("Удалить все подписки", role: .destructive) {
                            showConfirmationAlert = true
                        }
                    }
                    
                    // Отображение статуса операции
                    statusView
                }
                #endif
                
            }
            .navigationTitle("Настройки")
            .alert("Вы уверены?", isPresented: $showConfirmationAlert) {
                Button("Да, удалить все", role: .destructive) {
                    viewModel.deleteAllSubscriptions()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Это действие необратимо и удалит все подписки на уведомления (приглашения, команды, лимиты) для текущего аккаунта iCloud.")
            }
        }
    }
    
    /// Вспомогательная View для отображения результата
    @ViewBuilder
    private var statusView: some View {
        switch viewModel.deletionState {
        case .idle:
            EmptyView() // Ничего не показываем
            
        case .loading:
            HStack {
                ProgressView()
                Text("Удаление...")
                    .foregroundColor(.secondary)
            }
            
        case .success(let count):
            Text("Успешно удалено \(count) подписок.")
                .foregroundColor(.green)
            
        case .error(let errorMessage):
            VStack(alignment: .leading) {
                Text("Ошибка!")
                    .foregroundColor(.red)
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
