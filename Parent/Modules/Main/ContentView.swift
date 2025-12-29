//
//  ContentView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 10.11.2025.
//

import SwiftUI
import FamilyControls

struct ContentView: View {
    @EnvironmentObject var stateManager: AppStateManager
    @EnvironmentObject var authService: AuthenticationService
    @State private var showingSplash = true
    
    var body: some View {
        Group {
            if showingSplash {
                SplashScreenView() {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation {
                            showingSplash = false
                        }
                    }
                }
                .task {
                    await stateManager.initializeApp()
                }
            } else {
                mainContentView
            }
        }
    }
    @ViewBuilder
    private var mainContentView: some View {
        switch stateManager.appState {
        case .authRequired:
            AuthView()
            
        case .roleSelection:
            RoleSelectionView()
            
        case .parentAddChild:
            AddChildView()
            
        case .childPairing:
            ChildPairingView()
            
        case .parentDashboard:
            MainTabView()
            
        case .childDashboard:
            ChildDashboardView()
            
        case .accessDenied:
            AccessDeniedView()
        }
    }
}
