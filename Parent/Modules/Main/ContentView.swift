//
//  ContentView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 10.11.2025.
//

import SwiftUI
import FamilyControls

struct ContentView: View {
    @EnvironmentObject var stateManager: AuthenticationManager
    
    var body: some View {
        switch stateManager.appState {
        case .roleSelection:
            RoleSelectionView()
        case .parentSetup:
            ParentSetupView()
        case .childSetup:
            ChildSetupView()
        case .parentDashboard:
            ParentDashboardView()
        case .childDashboard:
            Text("Экран ребенка")
//            ChildDashboardView(user: ) // Главный экран ребенка
        case .accessDenied:
            Text("Какая-то херня")
//            AccessDeniedView()
        }
    }
}
