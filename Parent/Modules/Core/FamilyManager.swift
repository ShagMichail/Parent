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

class FamilyManager: ObservableObject {
    static let shared = FamilyManager()
    
    let authorizationCenter = AuthorizationCenter.shared
    let deviceActivityCenter = DeviceActivityCenter()
    let store = ManagedSettingsStore()
    
    @Published var authorizationStatus: AuthorizationStatus = .notDetermined
    @Published var familyMembers: [FamilyMember] = []
    @Published var selectedChild: FamilyMember?
    @Published var currentUser: FamilyMember?
    @Published var isFamilySetupCompleted = false
    
    var children: [FamilyMember] {
        familyMembers.filter { $0.type == .child }
    }
    
    // MARK: - Обратная совместимость - старый метод
    func setupFamilySharing() async throws {
        print("🔄 Начинаем настройку Family Sharing (совместимость)...")
        
        // Если текущий пользователь не родитель, выбрасываем ошибку
        guard let currentUser = currentUser, currentUser.type == .parent else {
            throw FamilyError.insufficientPermissions
        }
        
        try await setupRealFamilySharing()
    }
    
    // MARK: - Создание пользователя
    func createUser(name: String, appleId: String, role: MemberType) async throws {
        print("👤 Создаем пользователя: \(name), роль: \(role)")
        
        let user = FamilyMember(
            id: UUID().uuidString,
            name: name,
            type: role,
            appleId: appleId,
            deviceId: UIDevice.current.identifierForVendor?.uuidString
        )
        
        currentUser = user
        saveUserToStorage(user)
        
        // Если это родитель - настраиваем реальную Family Sharing
        if role == .parent {
            try await setupRealFamilySharing()
        }
        
        print("✅ Пользователь создан: \(name)")
    }
    
    // MARK: - Реальная настройка Family Sharing для родителя
    private func setupRealFamilySharing() async throws {
        print("🔄 Начинаем реальную настройку Family Sharing...")
        
        let status = authorizationCenter.authorizationStatus
        await MainActor.run {
            self.authorizationStatus = status
        }
        
        switch status {
        case .approved:
            print("✅ Авторизация уже получена")
            try await loadRealFamilyMembers()
            isFamilySetupCompleted = true
            
        case .notDetermined:
            print("📝 Запрашиваем авторизацию...")
            try await requestAuthorization()
            try await loadRealFamilyMembers()
            isFamilySetupCompleted = true
            
        case .denied:
            print("❌ Авторизация отклонена")
            throw FamilyError.authorizationDenied
        @unknown default:
            throw FamilyError.unknownAuthorizationStatus
        }
    }
    
    // MARK: - Запрос авторизации
    private func requestAuthorization() async throws {
        do {
            // Для родителя запрашиваем индивидуальную авторизацию
            try await authorizationCenter.requestAuthorization(for: .individual)
            
            let newStatus = authorizationCenter.authorizationStatus
            await MainActor.run {
                self.authorizationStatus = newStatus
            }
            
            if newStatus != .approved {
                throw FamilyError.authorizationDenied
            }
            
            print("✅ Авторизация FamilyControls получена")
            
        } catch {
            print("❌ Ошибка авторизации: \(error)")
            throw FamilyError.authorizationFailed(error)
        }
    }
    
    func loadRealFamily() async throws {
        try await loadRealFamilyMembers() // Просто вызываем существующий private метод
    }
    
    // MARK: - Загрузка реальных членов семьи через FamilyControls
    private func loadRealFamilyMembers() async throws {
        print("👨‍👩‍👧‍👦 Загружаем реальных членов семьи через FamilyControls...")
        
        // Проверяем, есть ли управляемые устройства через ManagedSettingsStore
        let managedDevices = await getManagedDevicesFromFamilyControls()
        
        await MainActor.run {
            self.familyMembers = managedDevices
            self.selectedChild = managedDevices.first(where: { $0.type == .child })
        }
        
        print("✅ Загружено реальных членов семьи: \(managedDevices.count)")
        
        // Если детей нет, предлагаем добавить
        if managedDevices.isEmpty {
            print("ℹ️ Детские устройства не найдены. Нужно добавить через системные настройки.")
        }
    }
    
    // MARK: - Получение управляемых устройств через FamilyControls
    private func getManagedDevicesFromFamilyControls() async -> [FamilyMember] {
        var members: [FamilyMember] = []
        
        // В реальном приложении здесь будет интеграция с FamilyControls API
        // для получения списка управляемых устройств
        
        // Пока эмулируем получение данных
        // В реальности нужно использовать ManagedSettingsStore и другие API
        
        // Добавляем текущего пользователя как родителя
        if let currentUser = currentUser {
            members.append(currentUser)
        }
        
        // Пытаемся обнаружить детские устройства
        // В реальном приложении это будет через:
        // - ManagedSettingsStore.shield.applications
        // - DeviceActivityCenter
        // - Системные API Family Sharing
        
        print("🔍 Поиск управляемых устройств...")
        
        // Здесь должна быть реальная логика обнаружения детей
        // Пока возвращаем пустой список - нужно добавить детей через системные настройки
        members.append(FamilyMember(id: "123", name: "Igor", type: .child, appleId: "dsasdf"))
        return members
    }
    
    // MARK: - Добавление ребенка через системные настройки
    func showAddChildScreen() {
        print("👶 Открываем экран добавления ребенка...")
        
        // Открываем системные настройки Family Sharing
        if let url = URL(string: "App-prefs:FAMILY") {
            UIApplication.shared.open(url)
        } else if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    
    // MARK: - Проверка статуса семьи
    func checkFamilyStatus() async -> FamilyStatus {
        guard let currentUser = currentUser, currentUser.type == .parent else {
            return .notParent
        }
        
        let status = authorizationCenter.authorizationStatus
        
        switch status {
        case .approved:
            let hasChildren = !children.isEmpty
            return hasChildren ? .setupWithChildren : .setupNoChildren
            
        case .notDetermined:
            return .notAuthorized
            
        case .denied:
            return .denied
            
        @unknown default:
            return .unknown
        }
    }
    
    // MARK: - Применение ограничений к реальному устройству ребенка
    func applyRestrictions(to child: FamilyMember, restrictions: ParentalRestrictions) async throws {
        print("🛡️ Применяем реальные ограничения для \(child.name)...")
        
        guard authorizationStatus == .approved else {
            throw FamilyError.notAuthorized
        }
        
        guard currentUser?.type == .parent else {
            throw FamilyError.insufficientPermissions
        }
        
        // Применяем реальные ограничения через ManagedSettingsStore
        await applyRealManagedSettings(restrictions)
        
        // Настраиваем реальные расписания
        try await setupRealDeviceActivitySchedules(restrictions)
        
        print("✅ Реальные ограничения применены для \(child.name)")
    }
    
    private func applyRealManagedSettings(_ restrictions: ParentalRestrictions) async {
        // Блокировка приложений через реальный FamilyControls
        if let appsToBlock = restrictions.appsToBlock {
            store.shield.applications = appsToBlock
        }
        
        // Веб-фильтрация
        if restrictions.webFiltering {
            store.webContent.blockedByFilter = .all()
        } else {
            store.webContent.blockedByFilter = .auto()
        }
        
        // Блокировка явного контента
        store.media.denyExplicitContent = restrictions.denyExplicitContent
        
        // Дополнительные реальные ограничения
//        store.passcode.lockAppOnSuspend = true
    }
    
    private func setupRealDeviceActivitySchedules(_ restrictions: ParentalRestrictions) async throws {
        guard let timeLimit = restrictions.dailyTimeLimit else { return }
        
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59),
            repeats: true
        )
        
        do {
            try await deviceActivityCenter.startMonitoring(
                DeviceActivityName("dailyLimit"),
                during: schedule
            )
            print("⏰ Реальное дневное расписание настроено")
        } catch {
            print("❌ Ошибка настройки реального расписания: \(error)")
            throw error
        }
    }
    
    // MARK: - Сохранение/загрузка пользователя
    private func saveUserToStorage(_ user: FamilyMember) {
        UserDefaults.standard.set(user.name, forKey: "currentUserName")
        UserDefaults.standard.set(user.appleId, forKey: "currentUserAppleId")
        UserDefaults.standard.set(user.type.rawValue, forKey: "currentUserRole")
        UserDefaults.standard.set(user.id, forKey: "currentUserId")
        UserDefaults.standard.set(isFamilySetupCompleted, forKey: "isFamilySetupCompleted")
    }
    
    func loadUserFromStorage() {
        guard let name = UserDefaults.standard.string(forKey: "currentUserName"),
              let appleId = UserDefaults.standard.string(forKey: "currentUserAppleId"),
              let roleString = UserDefaults.standard.string(forKey: "currentUserRole"),
              let role = MemberType(rawValue: roleString),
              let id = UserDefaults.standard.string(forKey: "currentUserId") else {
            return
        }
        
        let user = FamilyMember(
            id: id,
            name: name,
            type: role,
            appleId: appleId,
            deviceId: UIDevice.current.identifierForVendor?.uuidString
        )
        
        currentUser = user
        isFamilySetupCompleted = UserDefaults.standard.bool(forKey: "isFamilySetupCompleted")
        
        // Если это родитель и семья настроена - загружаем реальных членов семьи
        if role == .parent && isFamilySetupCompleted {
            Task {
                do {
                    try await loadRealFamilyMembers()
                } catch {
                    print("⚠️ Ошибка загрузки реальных членов семьи: \(error)")
                }
            }
        }
    }
    
    // MARK: - Выход
    func logout() {
        currentUser = nil
        familyMembers = []
        selectedChild = nil
        isFamilySetupCompleted = false
        
        UserDefaults.standard.removeObject(forKey: "currentUserName")
        UserDefaults.standard.removeObject(forKey: "currentUserAppleId")
        UserDefaults.standard.removeObject(forKey: "currentUserRole")
        UserDefaults.standard.removeObject(forKey: "currentUserId")
        UserDefaults.standard.removeObject(forKey: "isFamilySetupCompleted")
        
        clearAllRestrictions()
    }
    
    func clearAllRestrictions() {
        store.clearAllSettings()
    }
}

// MARK: - Статусы семьи
enum FamilyStatus {
    case notParent
    case notAuthorized
    case denied
    case setupNoChildren  // Семья настроена, но детей нет
    case setupWithChildren // Семья настроена с детьми
    case unknown
}

