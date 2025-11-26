//
//  ChildPairingView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 26.11.2025.
//

import SwiftUI

struct ChildPairingView: View {
    @EnvironmentObject var stateManager: AuthenticationManager
    
    // Состояния для управления UI
    @State private var invitationCode: String?
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 30) {
            // --- Заголовок ---
            VStack {
                Text("Настройка устройства")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text("Шаг 1 из 2")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)

            Spacer()

            // --- Основной контент (меняется в зависимости от состояния) ---
            if isLoading {
                ProgressView("Генерация кода...")
            } else if let code = invitationCode {
                // Состояние: Код сгенерирован, ждем родителя
                WaitingForParentView(invitationCode: code)
            } else {
                // Состояние: Начальное, кнопка для старта
                InitialSetupView(errorMessage: errorMessage) {
                    // Действие для кнопки "Сгенерировать код"
                    generateCodeAndSubscribe()
                }
            }
            
            Spacer()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("InvitationAccepted"))) { _ in
            // Получили уведомление, что родитель принял приглашение.
            // Переходим на следующий экран.
            print("ChildSetupView: Получено уведомление InvitationAccepted. Переход на childDashboard.")
            Task {
                // Ребенок сам удаляет свое приглашение из публичной базы
                if let code = invitationCode {
                    try? await CloudKitManager.shared.deleteInvitation(withCode: code)
                }
                // Переключаем глобальное состояние приложения
                stateManager.appState = .childDashboard
                stateManager.childDeviceDidPair()
            }
        }
    }
    
    /// Основная функция, которая запускает весь процесс со стороны ребенка
    private func generateCodeAndSubscribe() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                // 1. Создаем приглашение в CloudKit
                let code = try await CloudKitManager.shared.createInvitation()
                
                // 2. Подписываемся на обновления для этого приглашения
                try await CloudKitManager.shared.subscribeToInvitationUpdates(invitationCode: code)
                
                // 3. Обновляем UI, чтобы показать код
                self.invitationCode = code
                
            } catch {
                // В случае ошибки, показываем ее пользователю
                print("🚨 Ошибка в generateCodeAndSubscribe: \(error.localizedDescription)")
                self.errorMessage = "Не удалось создать приглашение. Проверьте подключение к интернету и iCloud."
            }
            
            isLoading = false
        }
    }
}
