//
//  ChildDashboardView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 11.11.2025.
//

import SwiftUI

// Экран для ребенка
struct ChildDashboardView: View {
//    let user: FamilyMember
    @EnvironmentObject var familyManager: FamilyManager
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "person.circle")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
//                Text("Привет, \(user.name)!")
                Text("Привет, Ваня!")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Это ваш детский аккаунт")
                    .foregroundColor(.secondary)
                
            }
            .padding()
            .navigationTitle("Мой аккаунт")
        }
    }
}
