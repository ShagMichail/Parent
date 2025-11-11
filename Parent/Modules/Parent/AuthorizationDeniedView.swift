//
//  AuthorizationDeniedView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 11.11.2025.
//

import SwiftUI

// Экран авторизации отклонена
struct AuthorizationDeniedView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "xmark.circle")
                .font(.system(size: 60))
                .foregroundColor(.red)
            
            Text("Доступ запрещен")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Для работы родительского контроля необходимо предоставить доступ в настройках Screen Time")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Button("Открыть настройки") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

