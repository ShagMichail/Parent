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
    
    // Данные пользователя, влияющие на навигацию
    @Published var userRole: UserRole = .unknown
    @Published var children: [Child] = []
    @Published var isPaired: Bool = false
    
    // Зависимость от сервиса авторизации
    private var authService: AuthenticationService
    private var cloudKitManager: CloudKitManager
    
    // Authorization Center (Screen Time)
    private let center = AuthorizationCenter.shared
    private var cancellables = Set<AnyCancellable>()
    
    // Ключи UserDefaults
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
                    self?.resetLocalState() // Чистим локальные данные при логауте
                    self?.appState = .authRequired
                }
            }
            .store(in: &cancellables)
    }
    
    /// ГЛАВНЫЙ МЕТОД: Запуск приложения и определение экрана
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
            // ✅ ВАЖНО: При запуске проверяем/обновляем подписку
            await setupChildSession()
        } else {
            // ... остальная логика ...
            determineNavigationPath()
        }
    }
    
    func didCompletePairing() {
        self.isPaired = true
        saveLocalState()
        appState = .childDashboard
        
        // ✅ ВАЖНО: Сразу подписываемся
        Task {
            await setupChildSession()
        }
    }
    
//    private func setupChildSession() async {
//        print("👶 Настройка сессии ребенка...")
//        
//        // Нам нужен RecordID ребенка.
//        // Если он есть в AuthService - берем оттуда, если нет - запрашиваем.
//        guard let childID = await cloudKitManager.fetchUserRecordID() else {
//            print("🚨 Ошибка: Не удалось получить ID ребенка для подписки")
//            return
//        }
//        
//        do {
//            // Вызываем тот самый метод, который ты написал в CloudKitManager
//            try await cloudKitManager.subscribeToCommands(for: childID)
//            print("✅ Ребенок успешно подписан на команды!")
//        } catch {
//            print("🚨 Ошибка подписки на команды: \(error)")
//        }
//    }
    
    
    /// Логика выбора экрана на основе данных
    private func determineNavigationPath() {
        // Если роль еще не выбрана -> экран выбора роли
        if userRole == .unknown {
            appState = .roleSelection
            return
        }
        
        // Если роль есть, проверяем разрешения Screen Time
        let status = center.authorizationStatus
        
        // Логика переходов
        if status == .approved {
            routeBasedOnRole()
        } else if status == .denied {
            appState = .accessDenied
        } else {
            // Если .notDetermined, мы можем либо показать выбор роли,
            // либо, если роль уже сохранена, форсировать запрос прав.
            // Для надежности отправим на выбор роли/прав.
            // Но если роль уже есть (например, Parent), лучше сразу запросить права или показать Dashboard.
            // В данном случае, пойдем по пути роли.
            routeBasedOnRole()
        }
    }
    
    /// Маршрутизация на основе Роли и Состояния данных
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
    
    // MARK: - User Actions (Действия пользователя, меняющие стейт)
    
    /// Пользователь выбрал роль
    func setRole(_ role: UserRole) {
        self.userRole = role
        saveLocalState()
        
        // После выбора роли обычно идет запрос прав ScreenTime,
        // который и триггернет обновление стейта через handleScreenTimeAuthStatus
    }
    
    /// Родитель добавил ребенка
    func didAddChild(_ child: Child) {
        self.children.append(child)
        saveLocalState()
        // Переход на дашборд
        appState = .parentDashboard
    }
    
    /// Ребенок завершил спаривание
    //    func didCompletePairing() {
    //        self.isPaired = true
    //        saveLocalState()
    //        appState = .childDashboard
    //    }
    
    /// Обработка изменения прав ScreenTime (системный коллбэк)
    private func handleScreenTimeAuthStatus(_ status: AuthorizationStatus) {
        print("🛡 ScreenTime Status changed: \(status)")
        
        // Если мы на сплэше или авторизации, игнорируем (ждем явной инициализации)
        if appState == .authRequired { return }
        
        if status == .denied {
            appState = .accessDenied
        } else if status == .approved {
            // Права получены, пересчитываем маршрут
            determineNavigationPath()
        }
    }
    
    // MARK: - Persistence (Сохранение состояния)
    
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
        // Загрузка роли
        if let data = UserDefaults.standard.data(forKey: userRoleKey),
           let role = try? JSONDecoder().decode(UserRole.self, from: data) {
            self.userRole = role
        }
        // Загрузка детей
        if let data = UserDefaults.standard.data(forKey: childrenKey),
           let list = try? JSONDecoder().decode([Child].self, from: data) {
            self.children = list
        }
        // Загрузка статуса спаривания
        self.isPaired = UserDefaults.standard.bool(forKey: isPairedKey)
    }
    
    private func resetLocalState() {
        userRole = .unknown
        children = []
        isPaired = false
        // Очистка UserDefaults...
        UserDefaults.standard.removeObject(forKey: userRoleKey)
        UserDefaults.standard.removeObject(forKey: childrenKey)
        UserDefaults.standard.removeObject(forKey: isPairedKey)
    }
    
    // MARK: - Вспомогательные методы запроса прав (вызывать из UI)
    
    func requestAuthorization() async {
        do {
            if userRole == .child {
                try await center.requestAuthorization(for: .child)
            } else {
                try await center.requestAuthorization(for: .individual)
            }
            // Успех обработается в handleScreenTimeAuthStatus
        } catch {
            print("Auth request failed: \(error)")
        }
    }
}

extension AppStateManager {
    private func setupChildSession() async {
        print("👶 Настройка сессии ребенка...")
        
        guard let childID = await cloudKitManager.fetchUserRecordID() else { return }
        
        // 1. СОХРАНЯЕМ ID В APP GROUP (Чтобы расширение его увидело)
        if let defaults = UserDefaults(suiteName: "group.com.laborato.test.Parent") { // ⚠️ ТВОЯ ГРУППА
            defaults.set(childID, forKey: "myChildRecordID")
        }
        
        // 2. ПОДПИСКА НА ПУШИ (Как и раньше)
        try? await cloudKitManager.subscribeToCommands(for: childID)
        
        try? await cloudKitManager.subscribeToScheduleChanges(for: childID)
        
        // 3. ЗАПУСК MONITOR EXTENSION (НОВОЕ!)
        startDeviceActivityMonitoring()
    }
    
    private func startDeviceActivityMonitoring() {
        let center = DeviceActivityCenter()
        let activityName = DeviceActivityName("dailyMonitor")
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0), // Начало дня
            intervalEnd: DateComponents(hour: 23, minute: 59), // Конец дня
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
