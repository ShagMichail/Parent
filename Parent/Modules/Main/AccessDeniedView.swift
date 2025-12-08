//
//  AccessDeniedView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 01.12.2025.
//

import SwiftUI

struct AccessDeniedView: View {
//    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            Text("Требуется доступ")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Для работы приложения необходимо предоставить доступ к управлению устройствами.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Button("Настройки") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            
            Button("Выйти") {
//                authManager.userRole = .unknown
//                authManager.appState = .roleSelection
            }
            .padding()
            .foregroundColor(.red)
        }
        .padding()
    }
}

