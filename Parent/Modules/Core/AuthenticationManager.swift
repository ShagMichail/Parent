//
//  AuthenticationManager.swift
//  Parent
//
//  Created by Михаил Шаговитов on 10.11.2025.
//

import SwiftUI
import Combine
import FamilyControls
import ManagedSettings

class AuthenticationManager: ObservableObject {
    static let shared = AuthenticationManager()
    
    let center = AuthorizationCenter.shared
    let store = ManagedSettingsStore()
    
    @Published var isAuthorized = false
    @Published var authorizationStatus: AuthorizationStatus = .notDetermined
    
    private init() {
        checkAuthorization()
    }
    
    func checkAuthorization() {
        Task { @MainActor in
            let status = center.authorizationStatus
            self.authorizationStatus = status
            self.isAuthorized = (status == .approved)
            print("Current authorization status: \(status)")
        }
    }
    
    func requestAuthorization() {
        print("Requesting authorization...")
        
        Task { @MainActor in
            do {
                let currentStatus = center.authorizationStatus
                print("Before request - status: \(currentStatus)")
                
                try await center.requestAuthorization(for: .individual)
                
                let newStatus = center.authorizationStatus
                print("After request - status: \(newStatus)")
                
                self.authorizationStatus = newStatus
                self.isAuthorized = (newStatus == .approved)
                
                if self.isAuthorized {
                    print("✅ Authorization SUCCESSFUL")
                } else {
                    print("❌ Authorization FAILED - status: \(newStatus)")
                }
                
            } catch {
                print("🚨 Authorization ERROR: \(error)")
                self.isAuthorized = false
            }
        }
    }
    
    func setRestrictions(_ selection: FamilyActivitySelection) {
        guard isAuthorized else {
            print("Cannot set restrictions - not authorized")
            return
        }
        
        store.shield.applications = selection.applicationTokens.isEmpty ? nil : selection.applicationTokens
        
        if selection.categoryTokens.isEmpty {
            store.shield.applicationCategories = nil
        } else {
            store.shield.applicationCategories = .specific(selection.categoryTokens)
        }
        
        store.shield.webDomains = selection.webDomainTokens.isEmpty ? nil : selection.webDomainTokens
        
        print("✅ Restrictions set")
    }
    
    func removeRestrictions() {
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.shield.webDomains = nil
        print("✅ All restrictions removed")
    }
}
