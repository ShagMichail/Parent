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
    @StateObject private var authManager = AuthenticationManager.shared
    @StateObject private var familyManager = FamilyManager.shared
    @StateObject private var cloudKitManager = CloudKitManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
                .environmentObject(familyManager)
                .environmentObject(cloudKitManager)
                .onAppear {
                    initializeApp()
                }
        }
    }
    
    private func initializeApp() {
        print("🚀 Инициализация приложения...")
//        authManager.checkAuthorization()
    }
}
