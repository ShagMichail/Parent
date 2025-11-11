//
//  ChildDashboardView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 11.11.2025.
//

import SwiftUI

// Экран для ребенка
struct ChildDashboardView: View {
    let user: FamilyMember
    @EnvironmentObject var familyManager: FamilyManager
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "person.circle")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("Привет, \(user.name)!")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Это ваш детский аккаунт")
                    .foregroundColor(.secondary)
                
                // Здесь можно показать текущие ограничения, статистику и т.д.
            }
            .padding()
            .navigationTitle("Мой аккаунт")
        }
    }
}
