//
//  ContentView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 10.11.2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var authManager: AuthenticationManager
    @EnvironmentObject private var familyManager: FamilyManager
    
    @State private var showLaunchScreen = true
    @State private var setupError: String?
    @State private var appState: AppState = .loading
    @State private var isUserLoaded = false // ✅ Новый флаг
    
    enum AppState {
        case loading, authorized, notAuthorized, roleSelection, error(String)
    }
    
    var body: some View {
        ZStack {
            if showLaunchScreen {
                LaunchScreenView()
            } else {
                mainContent
            }
        }
        .onAppear {
            setupApp()
        }
        .onChange(of: authManager.isAuthorized) {
            handleAuthorizationChange()
        }
        .onChange(of: familyManager.currentUser?.id) { oldId, newId in
            handleCurrentUserChange()
        }
    }
    
    private var mainContent: some View {
        Group {
            switch appState {
            case .loading:
                ProgressView("Загрузка...")
            case .error(let error):
                ErrorView(error: error)
            case .notAuthorized:
                AuthorizationView()
            case .roleSelection:
                RoleSelectionView()
            case .authorized:
                if familyManager.currentUser != nil {
                    UserSpecificView()
                } else {
                    RoleSelectionView()
                }
            }
        }
    }
    
    private func setupApp() {
        print("🚀 Запуск приложения...")
        
        // Загружаем сохраненного пользователя
        loadUserAndContinue()
    }
    
    private func loadUserAndContinue() {
        print("📦 Загружаем пользователя из хранилища...")
        
        // Загружаем пользователя
        familyManager.loadUserFromStorage()
        
        // Даем время на загрузку и затем продолжаем
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            print("👤 Пользователь загружен: \(familyManager.currentUser?.name ?? "nil")")
            isUserLoaded = true
            continueSetup()
        }
    }
    
    private func continueSetup() {
        print("🔍 Продолжаем настройку...")
        print("   - Пользователь: \(familyManager.currentUser?.name ?? "nil")")
        print("   - Авторизация: \(authManager.isAuthorized)")
        
        // Сначала проверяем авторизацию Screen Time
        authManager.checkAuthorization()
        
        // Определяем состояние приложения
        if !authManager.isAuthorized {
            appState = .notAuthorized
            showLaunchScreen = false
            print("❌ Нет авторизации Screen Time")
            return
        }
        
        // Проверяем, есть ли пользователь
        if familyManager.currentUser != nil {
            appState = .authorized
            showLaunchScreen = false
            print("✅ Переходим в приложение")
        } else {
            appState = .roleSelection
            showLaunchScreen = false
            print("🎭 Показываем выбор роли")
        }
    }
    
    private func handleAuthorizationChange() {
        print("🔄 Auth changed: \(authManager.isAuthorized)")
        
        if authManager.isAuthorized {
            if familyManager.currentUser != nil {
                appState = .authorized
            } else {
                appState = .roleSelection
            }
        } else {
            appState = .notAuthorized
        }
    }
    
    private func handleCurrentUserChange() {
        print("🔄 Current user changed: \(familyManager.currentUser?.name ?? "nil")")
        
        if familyManager.currentUser != nil {
            appState = .authorized
        } else {
            appState = .roleSelection
        }
    }
}
