//
//  ChildAuthorizationView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 26.11.2025.
//

import SwiftUI

struct ChildAuthorizationView: View {
    @EnvironmentObject var stateManager: AuthenticationManager
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "shield.lefthalf.filled")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text("Требуется разрешение")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("Чтобы приложение могло работать, попросите родителя предоставить необходимые разрешения для управления экранным временем.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            // Эта кнопка запускает системный диалог, требующий пароль родителя
            Button("Дать разрешение") {
                stateManager.requestChildAuthorization()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.top)
            
            Spacer()
            Spacer()
        }
        .padding(30)
    }
}
