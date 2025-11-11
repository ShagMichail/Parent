//
//  NoChildrenView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 11.11.2025.
//

import SwiftUI

// Экран когда детей нет
struct NoChildrenView: View {
    @EnvironmentObject var familyManager: FamilyManager
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "person.2.slash")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            Text("Дети не найдены")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Для использования родительского контроля необходимо добавить детские устройства через системные настройки Family Sharing")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Button("Добавить ребенка") {
                familyManager.showAddChildScreen()
            }
            .buttonStyle(.borderedProminent)
            
            Button("Обновить") {
                Task {
                    await refreshFamilyMembers()
                }
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
    
    private func refreshFamilyMembers() async {
        do {
            try await familyManager.loadRealFamily()
        } catch {
            print("Ошибка обновления: \(error)")
        }
    }
}
