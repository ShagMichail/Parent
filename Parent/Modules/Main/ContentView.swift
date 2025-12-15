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
                SplashScreenView()
                    .task {
                        await stateManager.initializeApp()
                    }
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            withAnimation {
                                showingSplash = false
                            }
                        }
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
