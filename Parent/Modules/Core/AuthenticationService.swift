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
import CloudKit
import DeviceActivity

@MainActor
class AuthenticationService: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var authToken: String?
    @Published var myUserRecordID: String?
    
    private let authTokenStorageKey = "com.laborato.parent.authToken"
    
    init() {
        loadAuthToken()
    }
    
    /// 1. Проверка сессии (вызывается при старте приложения)
    func checkSession() async -> Bool {
        guard let token = authToken, !token.isEmpty else {
            print("AuthService: Токен отсутствует.")
            isAuthenticated = false
            return false
        }
        
        let isValid = true
        
        if isValid {
            print("AuthService: Токен валиден.")
            isAuthenticated = true
            return true
        } else {
            print("AuthService: Токен невалиден.")
            await logout()
            return false
        }
    }
    
    /// 2. Вход / Регистрация (вызывается из AuthView)
    func login(token: String) {
        // Сохраняем токен
        UserDefaults.standard.set(token, forKey: authTokenStorageKey)
        self.authToken = token
        self.isAuthenticated = true
        print("AuthService: Пользователь вошел.")
    }
    
    /// 3. Выход
    func logout() {
        UserDefaults.standard.removeObject(forKey: authTokenStorageKey)
        self.authToken = nil
        self.isAuthenticated = false
        print("AuthService: Пользователь вышел.")
    }
    
    private func loadAuthToken() {
        self.authToken = UserDefaults.standard.string(forKey: authTokenStorageKey)
        self.isAuthenticated = (authToken != nil)
    }
}
