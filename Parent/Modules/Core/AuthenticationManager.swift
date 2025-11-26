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

enum AppState {
    case roleSelection
    case parentSetup
    case childAuthorization
    case childPairing
    case parentDashboard
    case childDashboard
    case accessDenied
}

@MainActor
class AuthenticationManager: ObservableObject, @preconcurrency CloudKitCommandExecutor {
    static let shared = AuthenticationManager()
    let store = ManagedSettingsStore()
    @Published var appState: AppState = .roleSelection
    
    let center = AuthorizationCenter.shared
    private var cancellables = Set<AnyCancellable>()
    @Published var myUserRecordID: String?
    
    @Published var children: [Child] = []
    
    @Published var userRole: UserRole = .unknown
    @Published var isPaired: Bool = false
    
    let dailyActivityName = DeviceActivityName("daily")
    
    // Ключи для сохранения в UserDefaults
    private let userRoleStorageKey = "app_user_role"
    private let childrenStorageKey = "managed_children_list"
    private let isPairedStorageKey = "app_is_paired_to_parent"
    
    init() {
        print("Запускаю проверку подключения к CloudKit при старте приложения...")
        loadUserRole()
        loadPairingStatus()
        updateInitialAppState()
        
        Task {
            await CloudKitManager.shared.runConnectivityTest()
        }
       
        // Подписываемся на изменения статуса
        center.$authorizationStatus
            .sink { [weak self] status in
                self?.handleAuthorizationChange(status: status)
            }
            .store(in: &cancellables)
        
        CloudKitManager.shared.commandExecutor = self
        
        // При запуске приложения получаем наш уникальный ID
        Task {
            self.myUserRecordID = await CloudKitManager.shared.fetchUserRecordID()
        }
        loadChildren()
        
        //#if DEBUG
        //        // Проверяем, нет ли уже в списке нашего тестового ребенка,
        //        // чтобы не добавлять его повторно при горячей перезагрузке SwiftUI.
        //        if !children.contains(where: { $0.name == "Тестовый Ребенок" }) {
        //            print("👨‍💻 DEBUG: Добавляю тестового ребенка для разработки.")
        //
        //            // Создаем фейкового ребенка с произвольными данными
        //            let debugChild = Child(
        //                id: UUID(),
        //                name: "Тестовый Ребенок",
        //                recordID: "fake_record_id_123" // Используем фейковый ID
        //            )
        //
        //            // Добавляем его в основной массив
        //            children.append(debugChild)
        //        }
        //#endif
    }
    
    private func loadPairingStatus() {
        if userRole == .child {
            self.isPaired = UserDefaults.standard.bool(forKey: isPairedStorageKey)
            print("✅ Статус привязки ребенка загружен: \(self.isPaired)")
        }
    }
    
    private func savePairingStatus(_ paired: Bool) {
        UserDefaults.standard.set(paired, forKey: isPairedStorageKey)
        self.isPaired = paired
        print("✅ Статус привязки ребенка сохранен: \(paired)")
    }
    
    private func loadUserRole() {
        if let data = UserDefaults.standard.data(forKey: userRoleStorageKey),
           let role = try? JSONDecoder().decode(UserRole.self, from: data) {
            self.userRole = role
            print("✅ Роль загружена: \(role.rawValue)")
        } else {
            print("ℹ️ Сохраненная роль не найдена. Будет показан экран выбора роли.")
        }
    }
    
    private func saveUserRole(_ role: UserRole) {
        if let data = try? JSONEncoder().encode(role) {
            UserDefaults.standard.set(data, forKey: userRoleStorageKey)
            self.userRole = role
            print("✅ Роль сохранена: \(role.rawValue)")
        }
    }
    
    private func updateInitialAppState() {
        guard userRole != .unknown else {
            self.appState = .roleSelection
            return
        }
        
        if center.authorizationStatus == .approved {
            if userRole == .parent {
                self.appState = .parentDashboard
            } else if userRole == .child {
                // Если ребенок авторизован, проверяем, привязан ли он
                self.appState = isPaired ? .childDashboard : .childPairing
            }
        } else {
            // Если разрешений нет
            self.appState = (userRole == .parent) ? .parentSetup : .childAuthorization
        }
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
    
    func executeCommand(name: String, recordID: CKRecord.ID) {
        print("🎬 Исполнение команды: \(name)")
        switch name {
        case "block_all_apps":
            store.shield.applicationCategories = .all()
            print("✅ Установлена блокировка на все категории приложений и веб-сайты.")
        case "unblock_all_apps":
            // Чтобы снять блокировку, мы просто присваиваем nil.
            store.shield.applicationCategories = nil
            store.shield.webDomains = nil
            
            print("✅ Блокировка снята.")
            
        default:
            print("⚠️ Неизвестная команда получена: \(name)")
        }
        
        Task {
            do {
                try await CloudKitManager.shared.publicDatabase.deleteRecord(withID: recordID)
                print("✅ Запись команды \(recordID.recordName) успешно удалена.")
            } catch {
                print("🚨 Не удалось удалить запись команды: \(error)")
            }
        }
    }
    
    func setupChildDevice() {
        guard let childID = self.myUserRecordID else {
            print("🚨 Невозможно подписаться на команды: ID ребенка неизвестен.")
            return
        }
        
        Task {
            do {
                try await CloudKitManager.shared.subscribeToCommands(for: childID)
                self.appState = .childDashboard
            } catch {
                print("🚨 Критическая ошибка подписки на команды: \(error)")
            }
        }
    }
    
    func sendBlockCommand(for childID: String) {
        Task {
            do {
                try await CloudKitManager.shared.sendCommand(name: "block_all_apps", to: childID)
            } catch {
                print("🚨 Ошибка отправки block команды: \(error)")
            }
        }
    }
    
    func sendUnblockCommand(for childID: String) {
        Task {
            do {
                try await CloudKitManager.shared.sendCommand(name: "unblock_all_apps", to: childID)
            } catch {
                print("🚨 Ошибка отправки unblock команды: \(error)")
            }
        }
    }
    
    func selectRole(_ role: MemberType) {
        let roleToSave: UserRole = (role == .parent) ? .parent : .child
        saveUserRole(roleToSave)
        
        if role == .parent {
            self.appState = .parentSetup
        } else {
            self.appState = .childAuthorization
        }
    }
    
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
        switch status {
        case .approved:
            if userRole == .parent {
                appState = .parentDashboard
            } else if userRole == .child {
                if isPaired {
                    print("ℹ️ Ребенок уже привязан. Переход на Dashboard.")
                    setupChildDevice()
                    appState = .childDashboard
                } else {
                    print("ℹ️ Ребенок еще не привязан. Переход на Pairing.")
                    appState = .childPairing
                }
            }
        case .denied:
            appState = .accessDenied
        case .notDetermined:
            if userRole == .parent {
                appState = .parentSetup
            } else if userRole == .child {
                appState = .childAuthorization
            } else {
                appState = .roleSelection
            }
        @unknown default:
            break
        }
    }
    
    func childDeviceDidPair() {
        print("👶 Ребенок успешно привязан!")
        
        savePairingStatus(true)
        saveUserRole(.child)
        setupChildDevice()
        startDeviceActivityMonitoring()
        
        self.appState = .childDashboard
    }
    
    func startDeviceActivityMonitoring() {
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        
        // Создаем расписание, которое активно каждый день с 00:00 до 23:59
        let schedule = DeviceActivitySchedule(
            intervalStart: Calendar.current.dateComponents([.hour, .minute, .second], from: startOfDay),
            intervalEnd: Calendar.current.dateComponents([.hour, .minute, .second], from: startOfDay.addingTimeInterval(86399)), // 23:59:59
            repeats: true // Повторять каждый день
        )
        
        let center = DeviceActivityCenter()
        do {
            try center.startMonitoring(dailyActivityName, during: schedule)
            print("✅ Мониторинг активности успешно запущен.")
        } catch {
            print("🚨 Ошибка при запуске мониторинга активности: \(error)")
        }
    }

}
