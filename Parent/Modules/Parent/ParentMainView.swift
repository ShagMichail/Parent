//
//  ParentMainView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 10.11.2025.
//

import SwiftUI

// Основной экран родителя с детьми
struct ParentMainView: View {
    @EnvironmentObject var familyManager: FamilyManager
    
    var body: some View {
        NavigationView {
            List {
                Section("Ваши дети") {
                    ForEach(familyManager.children) { child in
                        NavigationLink {
                            ChildManagementView(child: child)
                        } label: {
                            ChildRowView(child: child)
                        }
                    }
                }
                
                Section("Быстрые действия") {
                    Button("Добавить еще ребенка") {
                        familyManager.showAddChildScreen()
                    }
                    
                    Button("Настройки ограничений") {
                        // Переход к настройкам ограничений
                    }
                }
            }
            .navigationTitle("Родительский контроль")
            .refreshable {
                await refreshFamilyMembers()
            }
        }
    }
    
    private func refreshFamilyMembers() async {
        do {
            try await familyManager.loadRealFamily()
        } catch {
            print("Ошибка обновления: \(error)")
        }
    }
}
