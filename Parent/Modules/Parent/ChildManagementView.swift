//
//  ChildManagementView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 11.11.2025.
//

import SwiftUI

// Экран управления конкретным ребенком
struct ChildManagementView: View {
    let child: FamilyMember
    @EnvironmentObject var familyManager: FamilyManager
    
    var body: some View {
        Form {
            Section("Информация") {
                LabeledContent("Имя", value: child.name)
                LabeledContent("Apple ID", value: child.appleId)
            }
            
            Section("Ограничения") {
                NavigationLink("Настроить ограничения") {
//                    RestrictionsSetupView(child: child)
                }
                
                NavigationLink("Статистика использования") {
//                    UsageStatsView(child: child)
                }
            }
        }
        .navigationTitle(child.name)
    }
}
