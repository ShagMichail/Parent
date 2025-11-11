//
//  AuthorizationView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 10.11.2025.
//

import SwiftUI
import FamilyControls

struct AuthorizationView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "shield.lefthalf.filled")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("Родительский контроль")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Для работы приложения требуется разрешение на управление ограничениями экранного времени")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                Button("Предоставить доступ") {
                    Task {
                        authManager.requestAuthorization()
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                
                Button("Проверить статус") {
                    authManager.checkAuthorization()
                }
                .buttonStyle(SecondaryButtonStyle())
            }
            .padding(.horizontal, 40)
            
            // Отладочная информация
            VStack(spacing: 8) {
                Text("Статус: \(authManager.authorizationStatus.description)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if authManager.authorizationStatus == .denied {
                    Text("Доступ запрещен. Проверьте настройки Screen Time")
                        .font(.caption)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
        }
        .onAppear {
            authManager.checkAuthorization()
        }
        .onChange(of: authManager.isAuthorized) {
            print("AuthorizationView: isAuthorized = \(authManager.isAuthorized)")
        }
    }
}

// Расширение для красивого вывода статуса
extension AuthorizationStatus {
    var localizedDescription: String {
        switch self {
        case .notDetermined:
            return "Не определен"
        case .denied:
            return "Запрещен"
        case .approved:
            return "Разрешен"
        @unknown default:
            return "Неизвестно"
        }
    }
}
