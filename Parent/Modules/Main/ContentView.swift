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
                        // Ждем пока определится состояние или таймаут
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
            AuthView() // Внутри после входа вызывать authService.login(...) -> затем stateManager.initializeApp()
            
        case .roleSelection:
            RoleSelectionView()
            // Внутри: stateManager.setRole(.parent) -> stateManager.requestAuthorization()
            
        case .parentAddChild:
            AddChildView()
            // Внутри после сохранения: stateManager.didAddChild(newChild)
            
        case .childPairing:
            ChildPairingView()
            // Внутри после QR: stateManager.didCompletePairing()
            
        case .parentDashboard:
            MainTabView() // Главный экран родителя
            
        case .childDashboard:
            ChildDashboardView() // Главный экран ребенка
            
        case .accessDenied:
            AccessDeniedView()
        }
    }
}
