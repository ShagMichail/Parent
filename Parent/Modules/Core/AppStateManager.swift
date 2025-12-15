//
//  AppStateManager.swift
//  Parent
//
//  Created by Михаил Шаговитов on 05.12.2025.
//

import Foundation
import SwiftUI
import Combine
import FamilyControls
import ManagedSettings
import DeviceActivity

@MainActor
class AppStateManager: ObservableObject {
    @Published var appState: AppState = .authRequired
    @Published var userRole: UserRole = .unknown
    @Published var children: [Child] = []
    @Published var isPaired: Bool = false
    
    private var authService: AuthenticationService
    private var cloudKitManager: CloudKitManager
    private let center = AuthorizationCenter.shared
    private var cancellables = Set<AnyCancellable>()
    private let userRoleKey = "app_user_role"
    private let childrenKey = "managed_children_list"
    private let isPairedKey = "app_is_paired_to_parent"
    
    init(authService: AuthenticationService, cloudKitManager: CloudKitManager) {
        self.authService = authService
        self.cloudKitManager = cloudKitManager
        
        // Слушаем изменения авторизации ScreenTime
        center.$authorizationStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                self?.handleScreenTimeAuthStatus(status)
            }
            .store(in: &cancellables)
        
        // Слушаем изменения в AuthenticationService (если пользователь разлогинился)
        authService.$isAuthenticated
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isAuth in
                if !isAuth {
                    self?.resetLocalState()
                    self?.appState = .authRequired
                }
            }
            .store(in: &cancellables)
    }
    
    
    // MARK: Public Method
    
    // Запуск приложения и определение экрана
    func initializeApp() async {
        print("📱 StateManager: Инициализация приложения...")
        
        // 1. Проверяем токен через AuthService
        let isSessionValid = await authService.checkSession()
        
        guard isSessionValid else {
            appState = .authRequired
            return
        }
        
        // 2. Если авторизованы, загружаем локальные настройки (роль, дети)
        loadLocalState()
        
        if userRole == .child && isPaired {
            appState = .childDashboard
            await setupChildSession()
        } else {
            determineNavigationPath()
        }
    }
    
    func setRole(_ role: UserRole) {
        self.userRole = role
        saveLocalState()
    }
    
    /// Родитель добавил ребенка
    func didAddChild(_ child: Child) {
        self.children.append(child)
        saveLocalState()
        appState = .parentDashboard
    }
    
    func didCompletePairing() {
        self.isPaired = true
        saveLocalState()
        appState = .childDashboard
        
        Task {
            await setupChildSession()
        }
    }
    
    
    // MARK: Privale Method
    
    private func determineNavigationPath() {
        if userRole == .unknown {
            appState = .roleSelection
            return
        }
        let status = center.authorizationStatus
        
        if status == .approved {
            routeBasedOnRole()
        } else if status == .denied {
            appState = .accessDenied
        } else {
            routeBasedOnRole()
        }
    }
    
    private func routeBasedOnRole() {
        switch userRole {
        case .parent:
            if children.isEmpty {
                print("👨‍👩‍👧 Родитель: Нет детей -> AddChild")
                appState = .parentAddChild
            } else {
                print("👨‍👩‍👧 Родитель: Все ок -> Dashboard")
                appState = .parentDashboard
            }
            
        case .child:
            if isPaired {
                print("👶 Ребенок: Привязан -> Dashboard")
                appState = .childDashboard
                // Тут можно запустить фоновые процессы ребенка
            } else {
                print("👶 Ребенок: Не привязан -> Pairing")
                appState = .childPairing
            }
            
        case .unknown:
            appState = .roleSelection
        }
    }

    // Обработка изменения прав ScreenTime (системный коллбэк)
    private func handleScreenTimeAuthStatus(_ status: AuthorizationStatus) {
        print("🛡 ScreenTime Status changed: \(status)")
        if appState == .authRequired { return }
        
        if status == .denied {
            appState = .accessDenied
        } else if status == .approved {
            determineNavigationPath()
        }
    }
    
    private func saveLocalState() {
        if let data = try? JSONEncoder().encode(userRole) {
            UserDefaults.standard.set(data, forKey: userRoleKey)
        }
        if let data = try? JSONEncoder().encode(children) {
            UserDefaults.standard.set(data, forKey: childrenKey)
        }
        UserDefaults.standard.set(isPaired, forKey: isPairedKey)
    }
    
    private func loadLocalState() {
        if let data = UserDefaults.standard.data(forKey: userRoleKey),
           let role = try? JSONDecoder().decode(UserRole.self, from: data) {
            self.userRole = role
        }
        if let data = UserDefaults.standard.data(forKey: childrenKey),
           let list = try? JSONDecoder().decode([Child].self, from: data) {
            self.children = list
        }
        self.isPaired = UserDefaults.standard.bool(forKey: isPairedKey)
    }
    
    private func resetLocalState() {
        userRole = .unknown
        children = []
        isPaired = false
        UserDefaults.standard.removeObject(forKey: userRoleKey)
        UserDefaults.standard.removeObject(forKey: childrenKey)
        UserDefaults.standard.removeObject(forKey: isPairedKey)
    }
    
    func requestAuthorization() async {
        do {
            if userRole == .child {
                try await center.requestAuthorization(for: .child)
            } else {
                try await center.requestAuthorization(for: .individual)
            }
        } catch {
            print("Auth request failed: \(error)")
        }
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("✅ Разрешение на уведомления получено")
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                print("❌ Пользователь запретил уведомления: \(String(describing: error))")
            }
        }
    }
}

extension AppStateManager {
    private func setupChildSession() async {
        print("👶 Настройка сессии ребенка...")
        
        guard let childID = await cloudKitManager.fetchUserRecordID() else { return }
        
        // 1. СОХРАНЯЕМ ID В APP GROUP
        if let defaults = UserDefaults(suiteName: "group.com.laborato.test.Parent") {
            defaults.set(childID, forKey: "myChildRecordID")
        }
        
        // 2. ПОДПИСКА НА ПУШИ
        try? await cloudKitManager.subscribeToCommands(for: childID)
        try? await cloudKitManager.subscribeToScheduleChanges(for: childID)
        
        // 3. ЗАПУСК MONITOR EXTENSION
        startDeviceActivityMonitoring()
        await FocusScheduleManager.shared.syncFromCloudKit()
    }
    
    private func startDeviceActivityMonitoring() {
        let center = DeviceActivityCenter()
        let activityName = DeviceActivityName("dailyMonitor")
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59),
            repeats: true
        )
        
        do {
            try center.startMonitoring(activityName, during: schedule)
            print("✅ Device Monitor запущен. Расширение будет следить за устройством.")
        } catch {
            print("🚨 Ошибка запуска монитора: \(error)")
        }
    }
}
