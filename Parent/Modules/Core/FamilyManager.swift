//
//  FamilyManager.swift
//  Parent
//
//  Created by Михаил Шаговитов on 10.11.2025.
//

import SwiftUI
import FamilyControls
import ManagedSettings
import DeviceActivity

enum FamilySharingStatus {
    case notSetup
    case activeNoChildren
    case activeWithChildren
    case denied
    case unknown
}

enum FamilyStatus {
    case notAuthorized
    case denied
    case setupNoChildren
    case setupWithChildren
}

class FamilyManager: ObservableObject {
    static let shared = FamilyManager()
    
    @Published var currentUser: FamilyMember?
    
    let store = ManagedSettingsStore()
    private let center = DeviceActivityCenter()
    
    init() {
        loadUserFromStorage()
    }
    
    func setBlockedItems(from selection: FamilyActivitySelection) {
        let applicationTokens = Set(selection.applicationTokens)
        let categoryTokens = Set(selection.categoryTokens)
        
        store.shield.applications = applicationTokens.isEmpty ? nil : applicationTokens
        store.shield.applicationCategories = categoryTokens.isEmpty ? nil : .specific(categoryTokens, except: Set())
    }
    
    private func saveUserToStorage(_ user: FamilyMember) { /*...*/ }
    func loadUserFromStorage() { /*...*/ }
}

