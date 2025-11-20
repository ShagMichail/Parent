//
//  RoleSelectionView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 10.11.2025.
//

import SwiftUI

struct RoleSelectionView: View {
    @EnvironmentObject var stateManager: AuthenticationManager
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Родительский контроль")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            VStack(spacing: 20) {
                Button("Войти как родитель") {
                    stateManager.selectRole(.parent)
                }
                .buttonStyle(PrimaryButtonStyle())
                
                Button("Войти как ребенок") {
                    stateManager.selectRole(.child)
                }
                .buttonStyle(SecondaryButtonStyle())
            }
            .padding(.horizontal, 40)
            
            Text("Для работы требуется Apple ID и подключение к iCloud")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
}
