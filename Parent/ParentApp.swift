//
//  ParentApp.swift
//  Parent
//
//  Created by Михаил Шаговитов on 10.11.2025.
//

import SwiftUI

@main
struct ParentApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var cloudKitManager: CloudKitManager
    @StateObject var stateManager: AppStateManager
    @StateObject var authService: AuthenticationService
    
    init() {
        print("🚀 ParentApp init: Создаем сервисы...")
        let authServiceInstance = AuthenticationService()
        let cloudKitManager = CloudKitManager()
        let stateManagerInstance = AppStateManager(authService: authServiceInstance, cloudKitManager: cloudKitManager)
        _authService = StateObject(wrappedValue: authServiceInstance)
        _cloudKitManager = StateObject(wrappedValue: cloudKitManager)
        _stateManager = StateObject(wrappedValue: stateManagerInstance)
    }
      
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(stateManager)
                .environmentObject(authService)
                .environmentObject(cloudKitManager)
        }
    }
}
