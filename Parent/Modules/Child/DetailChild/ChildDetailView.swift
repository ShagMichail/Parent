//
//  Untitled.swift
//  Parent
//
//  Created by Михаил Шаговитов on 10.11.2025.
//

import SwiftUI

struct ChildDetailView: View {
    let child: FamilyMember  // Изменили на FamilyMember
    @EnvironmentObject var parentManager: FamilyManager
    @State private var showingRestrictions = false
    @State private var showingTimeLimit = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Карточка информации
                ChildInfoCard(child: child)
                
                // Быстрые действия (нужно будет обновить QuickChildActionsView)
//                QuickChildActionsView(
//                    child: child,
//                    showingRestrictions: $showingRestrictions,
//                    showingTimeLimit: $showingTimeLimit
//                )
                
                // Статистика использования (нужно будет обновить ChildUsageStatsView)
//                ChildUsageStatsView(child: child)
                
                // Активные ограничения (нужно будет обновить ChildRestrictionsView)
//                ChildRestrictionsView(child: child)
                
                // Если у ребенка есть свои дети, показываем список
                if !child.children.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Дети")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ChildrenListView(children: child.children)
                            .frame(height: 200)
                    }
                }
            }
            .padding()
        }
        .navigationTitle(child.name)
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showingRestrictions) {
//            ChildRestrictionsPickerView(child: child)
        }
        .sheet(isPresented: $showingTimeLimit) {
//            ChildTimeLimitView(child: child)
        }
    }
}
