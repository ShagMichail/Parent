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

enum AppState {
    case roleSelection
    case parentSetup
    case childSetup
    case parentDashboard
    case childDashboard
    case accessDenied
}

@MainActor
class AuthenticationManager: ObservableObject, CloudKitCommandReceiver {
    static let shared = AuthenticationManager()
    
    @Published var appState: AppState = .roleSelection
    
    let center = AuthorizationCenter.shared
    private var cancellables = Set<AnyCancellable>()
    @Published var myUserRecordID: String?
    
    @Published var children: [Child] = []
    
    private let childrenStorageKey = "managed_children_list"
    
    init() {
        print("Запускаю проверку подключения к CloudKit при старте приложения...")
        Task {
            await CloudKitManager.shared.runConnectivityTest()
        }
        // При старте приложения проверяем, не был ли доступ уже дан ранее.
        // Это позволит сразу перекинуть пользователя на главный экран.
        if center.authorizationStatus == .approved {
            // Здесь есть нюанс: мы не знаем, это родитель или ребенок.
            // Можно сохранять выбранную роль в UserDefaults после первого выбора.
            // Для простоты пока будем начинать с выбора роли.
            // TODO: Загрузить сохраненную роль из UserDefaults
        }
        
        // Подписываемся на изменения статуса
        center.$authorizationStatus
            .sink { [weak self] status in
                self?.handleAuthorizationChange(status: status)
            }
            .store(in: &cancellables)
        
        CloudKitManager.shared.commandReceiver = self
        
        // При запуске приложения получаем наш уникальный ID
        Task {
            self.myUserRecordID = await CloudKitManager.shared.fetchUserRecordID()
        }
        loadChildren()
    }
    
    func addChild(name: String, recordID: String) {
        let newChild = Child(id: UUID(), name: name, recordID: recordID)
        children.append(newChild)
        saveChildren()
    }
    
    private func saveChildren() {
        if let encodedData = try? JSONEncoder().encode(children) {
            UserDefaults.standard.set(encodedData, forKey: childrenStorageKey)
        }
    }
    
    private func loadChildren() {
        if let savedData = UserDefaults.standard.data(forKey: childrenStorageKey),
           let decodedChildren = try? JSONDecoder().decode([Child].self, from: savedData) {
            self.children = decodedChildren
        }
    }
    
    func executeCommand(_ commandName: String) {
        let store = ManagedSettingsStore()
        
        switch commandName {
        case "block_all":
            print("🎬 Исполняю команду: Заблокировать все")
            store.shield.applicationCategories = .all()
        case "unblock_all":
            print("🎬 Исполняю команду: Разблокировать все")
            store.shield.applicationCategories = nil
        default:
            print("⚠️ Неизвестная команда: \(commandName)")
        }
    }
    
    func setupChildDevice() {
        let childID = "some_unique_child_id"
        Task {
            do {
                try await CloudKitManager.shared.subscribeToCommands(for: childID)
                self.appState = .childDashboard
            } catch {
                print("🚨 Ошибка подписки на команды: \(error)")
            }
        }
    }
    
    func sendBlockCommand(for childID: String) {
        Task {
            do {
                try await CloudKitManager.shared.sendCommand(name: "block_all", to: childID)
            } catch {
                print("🚨 Ошибка отправки block команды: \(error)")
            }
        }
    }
    
    func sendUnblockCommand(for childID: String) {
        Task {
            do {
                try await CloudKitManager.shared.sendCommand(name: "unblock_all", to: childID)
            } catch {
                print("🚨 Ошибка отправки unblock команды: \(error)")
            }
        }
    }
    
    /// Вызывается из RoleSelectionView
    func selectRole(_ role: MemberType) {
        switch role {
        case .parent:
            appState = .parentSetup
        case .child:
            appState = .childSetup
        }
    }
    
    /// Вызывается из ParentSetupView. Инициирует удаленную настройку.
    func requestParentAuthorization() {
        Task {
            do {
                try await center.requestAuthorization(for: .individual)
            } catch {
                print("Ошибка при запросе авторизации родителя: \(error)")
                appState = .accessDenied
            }
        }
    }
    
    /// Вызывается из ChildSetupView. Инициирует настройку на устройстве ребенка.
    func requestChildAuthorization() {
        Task {
            do {
                try await center.requestAuthorization(for: .child)
            } catch {
                print("Ошибка при запросе авторизации ребенка: \(error)")
                appState = .accessDenied
            }
        }
    }
    
    private func handleAuthorizationChange(status: AuthorizationStatus) {
        // Этот метод будет вызван после любого запроса авторизации
        switch status {
        case .approved:
            // После успешного разрешения, переходим на соответствующий главный экран.
            // Здесь нам нужно знать, кто мы - родитель или ребенок.
            // Логика ниже предполагает, что мы знаем роль из предыдущего шага.
            if appState == .parentSetup {
                appState = .parentDashboard
            } else if appState == .childSetup {
                // После того как родитель ввел пароль на устройстве ребенка
                appState = .childDashboard // или просто информационный экран
                setupChildDevice()
            }
        case .denied:
            appState = .accessDenied
        case .notDetermined:
            // Если статус сбросился, возвращаемся к выбору роли
            appState = .roleSelection
        @unknown default:
            break
        }
    }
}
