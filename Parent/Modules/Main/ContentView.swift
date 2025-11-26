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
            
        case .childAuthorization:
            ChildAuthorizationView()
            
        case .childPairing:
            ChildPairingView()
            
        case .parentDashboard:
            ParentDashboardView()
            
        case .childDashboard:
            ChildDashboardView() 
            
        case .accessDenied:
            Text("hello")
            //               AccessDeniedView()   // Замените на ваш экран ошибки
        }
    }
}
