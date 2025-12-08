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

//enum AppState {
//    case authRequired
//    case roleSelection
//    case parentAddChild
//    case childPairing
//    case parentDashboard
//    case childDashboard
//    case accessDenied
//}
//
//@MainActor
//class AuthenticationManager: ObservableObject, @preconcurrency CloudKitCommandExecutor {
//    static let shared = AuthenticationManager()
//    let store = ManagedSettingsStore()
//    @Published var appState: AppState = .authRequired
//
//    // 3. Свойство для хранения токена
//    @Published var authToken: String?
//
//    // Ключ для хранения токена в Keychain (безопасное хранилище)
//    private let authTokenStorageKey = "com.laborato.parent.authToken"
//
//    @Published var isLoading = true // Добавляем индикатор загрузки
//
//    let center = AuthorizationCenter.shared
//    private var cancellables = Set<AnyCancellable>()
//    @Published var myUserRecordID: String?
//
//    @Published var children: [Child] = []
//
//    @Published var userRole: UserRole = .unknown
//    @Published var isPaired: Bool = false
//
//    let dailyActivityName = DeviceActivityName("daily")
//
//    // Ключи для сохранения в UserDefaults
//    private let userRoleStorageKey = "app_user_role"
//    private let childrenStorageKey = "managed_children_list"
//    private let isPairedStorageKey = "app_is_paired_to_parent"
//
//    // В AuthenticationManager.swift
//
//    init() {
//        // --- ПОДГОТОВИТЕЛЬНЫЙ ЭТАП (синхронный) ---
//
//        // 1. Назначаем делегатов
//        CloudKitManager.shared.commandExecutor = self
//        // CloudKitManager.shared.invitationReceiver = self // Если у вас есть этот протокол
//
//        // 2. Подписываемся на изменения авторизации FamilyControls.
//        // Это важно делать сразу, чтобы не пропустить события.
//        center.$authorizationStatus
//            .sink { [weak self] status in
//                self?.handleAuthorizationChange(status: status)
//            }
//            .store(in: &cancellables)
//
//        // --- ОСНОВНОЙ ЭТАП (асинхронный) ---
//
//        // 3. Запускаем единую асинхронную задачу для определения состояния.
//        Task {
//            await initializeAppState()
//        }
//    }
//
//    /// Единая функция, которая определяет начальное состояние приложения.
//    private func initializeAppState() async {
////        print("🚀 Запуск асинхронной инициализации...")
////
////        // ШАГ 1: ПРОВЕРКА АУТЕНТИФИКАЦИИ НА НАШЕМ СЕРВЕРЕ
////        await loadAuthToken()
////
////        guard let token = self.authToken else {
////            // Если токена нет, сразу на экран входа.
////            await MainActor.run {
////                self.appState = .authRequired
////                self.isLoading = false
////            }
////            print("🛑 Инициализация завершена: Токен не найден, требуется вход.")
////            return
////        }
////
////        let isTokenValid = await APIManager.shared.validateToken(token)
////
////        guard isTokenValid else {
////            // Если токен есть, но он невалиден, тоже на экран входа.
////            await MainActor.run {
////                self.appState = .authRequired
////                self.isLoading = false
////            }
////            print("🛑 Инициализация завершена: Токен невалиден, требуется вход.")
////            return
////        }
////
////        print("✅ Токен валиден.")
//
//        // ШАГ 2: ПОЛЬЗОВАТЕЛЬ АУТЕНТИФИЦИРОВАН. ЗАГРУЖАЕМ ЕГО ДАННЫЕ И НАСТРОЙКИ.
//
//        // Загружаем сохраненную роль, список детей и т.д.
//        // Выполняем это в одной группе, чтобы ускорить процесс.
//        //        await Task.detached {
//        // Мы можем выполнять загрузку из UserDefaults в фоновом потоке
//        self.loadUserRole()
//        self.loadPairingStatus()
//        self.loadChildren()
//        self.myUserRecordID = await CloudKitManager.shared.fetchUserRecordID()
//
//        // Сохраняем ID для расширения, если это ребенок
//        if let id = self.myUserRecordID, self.userRole == .child {
//            UserDefaults(suiteName: "group.com.laborato.test.Parent")?.set(id, forKey: "myUserRecordID")
//        }
//        //        }.value // .value дожидается завершения
//
//
//        // ШАГ 3: ОПРЕДЕЛЯЕМ СЛЕДУЮЩИЙ ЭКРАН (старый метод `determineInitialState`)
//
//        // Теперь, когда все данные загружены, вызываем логику определения UI
//        await determineNextScreen()
//    }
//
//
//    // Переименовываем `determineInitialState` для ясности
//    private func determineNextScreen() async {
//        print("🔍 Определяю следующий экран...")
//
//        let currentAuthStatus = center.authorizationStatus
//
//        await MainActor.run {
//            if userRole == .unknown {
//                // Если роль не выбрана (например, новый пользователь), отправляем на выбор роли.
//                appState = .roleSelection
//                isLoading = false
//                return
//            }
//
//            // Эта логика остается почти такой же, как у вас и была
//            switch currentAuthStatus {
//            case .approved:
//                if userRole == .parent {
//                    // ЕСЛИ Я РОДИТЕЛЬ И У МЕНЯ НЕТ ДЕТЕЙ,
//                    // ТО Я ИДУ НА ЭКРАН ДОБАВЛЕНИЯ РЕБЕНКА.
//                    if children.isEmpty {
//                        print("ℹ️ Родитель авторизован, но детей нет. Переход к добавлению.")
//                        appState = .parentAddChild
//                    } else {
//                        // Если дети есть, иду на главный экран.
//                        print("ℹ️ Родитель авторизован, дети есть. Переход на Dashboard.")
//                        appState = .parentDashboard
//                    }
//                } else if userRole == .child {
//                    // Логика для ребенка остается той же
//                    if isPaired {
//                        appState = .childDashboard
//                        setupChildDevice()
////                        scheduleNextDeviceActivityCheck()
//                    } else {
//                        appState = .childPairing
//                    }
//                }
//
//            case .denied:
//                appState = .accessDenied
//
//            case .notDetermined:
//                // ЕСЛИ РАЗРЕШЕНИЙ НЕТ,
//                // ОСТАЕМСЯ НА ЭКРАНЕ ВЫБОРА РОЛИ.
//                // Пользователь сам инициирует запрос.
//                appState = .roleSelection
//
//            @unknown default:
//                appState = .roleSelection
//            }
//
//            isLoading = false
//            print("✅ Начальное состояние установлено: \(appState)")
//        }
//    }
//
////    private func loadUserRoleAndDetermineState() async {
////        loadUserRole()
////        loadPairingStatus()
////        await determineInitialState() // Ваш существующий метод
////    }
//
//    /// Сохраняет токен в безопасное хранилище Keychain
//    func saveAuthToken(_ token: String) async {
//        // TODO: Реализовать сохранение в Keychain. Для простоты пока используем UserDefaults.
//        UserDefaults.standard.set(token, forKey: authTokenStorageKey)
//        await MainActor.run {
//            self.authToken = token
//        }
//    }
//
//    /// Загружает токен из Keychain
//    func loadAuthToken() async {
//        // TODO: Реализовать загрузку из Keychain.
//        if let token = UserDefaults.standard.string(forKey: authTokenStorageKey) {
//            await MainActor.run {
//                self.authToken = token
//            }
//        }
//    }
//
//    /// Выход из системы
//    func logout() async {
//        // TODO: Реализовать удаление из Keychain
//        UserDefaults.standard.removeObject(forKey: authTokenStorageKey)
//        await MainActor.run {
//            self.authToken = nil
//            // Сбрасываем все состояния
//            self.userRole = .unknown
//            self.isPaired = false
//            self.appState = .authRequired
//        }
//    }
//
//    // --- ОБНОВЛЕНИЕ ЛОГИКИ ПОСЛЕ УСПЕШНОГО ВХОДА ---
//
//    /// Этот метод должен быть вызван после успешной регистрации или входа
//    func userDidAuthenticate(token: String) {
//        Task {
//            // 1. Сохраняем полученный токен
//            await saveAuthToken(token)
//
//            // 2. Запускаем флоу выбора роли и т.д.
//            // (Предполагаем, что после первого входа роль еще не выбрана)
//            await MainActor.run {
//                // Здесь можно запросить с сервера роль, если она уже была выбрана
//                // Для простоты, отправляем на выбор роли
//                self.appState = .roleSelection
//            }
//        }
//    }
//
//
//    // Новая функция для определения начального состояния
////    func determineInitialState() async {
////        print("🔍 Определяю начальное состояние приложения...")
////
////        // Ждем немного, чтобы все подписки успели инициализироваться
////        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 секунды
////
////        let currentAuthStatus = center.authorizationStatus
////        print("📊 Текущий статус авторизации: \(currentAuthStatus)")
////        print("📊 Текущая роль: \(userRole)")
////        print("📊 Статус привязки: \(isPaired)")
////
////        await MainActor.run {
////            if userRole == .unknown {
////                appState = .roleSelection
////                isLoading = false
////                return
////            }
////
////            switch currentAuthStatus {
////            case .approved:
////                if userRole == .parent {
////                    appState = .parentDashboard
////                } else if userRole == .child {
////                    appState = isPaired ? .childDashboard : .childPairing
////                    // Если ребенок привязан, настраиваем устройство
////                    if isPaired {
////                        setupChildDevice()
////                        scheduleNextDeviceActivityCheck()()
////                    }
////                }
////
////            case .denied:
////                appState = .accessDenied
////
////            case .notDetermined:
////                // ЕСЛИ РАЗРЕШЕНИЙ НЕТ,
////                // ОСТАЕМСЯ НА ЭКРАНЕ ВЫБОРА РОЛИ.
////                // Пользователь сам инициирует запрос.
////                appState = .roleSelection
////
////            @unknown default:
////                appState = .roleSelection
////            }
////
////            isLoading = false
////            print("✅ Начальное состояние установлено: \(appState)")
////        }
////    }
//
//    // Остальные методы остаются без изменений...
//    private func loadPairingStatus() {
//        if userRole == .child {
//            self.isPaired = UserDefaults.standard.bool(forKey: isPairedStorageKey)
//            print("✅ Статус привязки ребенка загружен: \(self.isPaired)")
//        }
//    }
//
//    private func savePairingStatus(_ paired: Bool) {
//        UserDefaults.standard.set(paired, forKey: isPairedStorageKey)
//        self.isPaired = paired
//        print("✅ Статус привязки ребенка сохранен: \(paired)")
//    }
//
//    private func loadUserRole() {
//        if let data = UserDefaults.standard.data(forKey: userRoleStorageKey),
//           let role = try? JSONDecoder().decode(UserRole.self, from: data) {
//            self.userRole = role
//            print("✅ Роль загружена: \(role.rawValue)")
//        } else {
//            print("ℹ️ Сохраненная роль не найдена. Будет показан экран выбора роли.")
//        }
//    }
//
//    private func saveUserRole(_ role: UserRole) {
//        if let data = try? JSONEncoder().encode(role) {
//            UserDefaults.standard.set(data, forKey: userRoleStorageKey)
//            self.userRole = role
//            print("✅ Роль сохранена: \(role.rawValue)")
//        }
//    }
//
//    // Удаляем старый updateInitialAppState или делаем его приватным
//    private func updateInitialAppState() {
//        // Этот метод больше не используется напрямую
//    }
//
//    // Остальные методы остаются без изменений...
//    func addChild(name: String, recordID: String) {
//        let newChild = Child(id: UUID(), name: name, recordID: recordID)
//        children.append(newChild)
//        saveChildren()
//    }
//
//    private func saveChildren() {
//        if let encodedData = try? JSONEncoder().encode(children) {
//            UserDefaults.standard.set(encodedData, forKey: childrenStorageKey)
//        }
//    }
//
//    private func loadChildren() {
//        if let savedData = UserDefaults.standard.data(forKey: childrenStorageKey),
//           let decodedChildren = try? JSONDecoder().decode([Child].self, from: savedData) {
//            self.children = decodedChildren
//        }
//    }
//
//    func executeCommand(name: String, recordID: CKRecord.ID) {
//        print("🎬 Исполнение команды: \(name)")
//        switch name {
//        case "block_all_apps":
//            store.shield.applicationCategories = .all()
//            print("✅ Установлена блокировка на все категории приложений и веб-сайты.")
//        case "unblock_all_apps":
//            store.shield.applicationCategories = nil
//            store.shield.webDomains = nil
//            print("✅ Блокировка снята.")
//
//        default:
//            print("⚠️ Неизвестная команда получена: \(name)")
//        }
//
//        Task {
//            do {
//                try await CloudKitManager.shared.publicDatabase.deleteRecord(withID: recordID)
//                print("✅ Запись команды \(recordID.recordName) успешно удалена.")
//            } catch {
//                print("🚨 Не удалось удалить запись команды: \(error)")
//            }
//        }
//    }
//
//    func setupChildDevice() {
//        guard let childID = self.myUserRecordID else {
//            print("🚨 Невозможно подписаться на команды: ID ребенка неизвестен.")
//            return
//        }
//
//        Task {
//            do {
//                try await CloudKitManager.shared.subscribeToCommands(for: childID)
//                self.appState = .childDashboard
//            } catch {
//                print("🚨 Критическая ошибка подписки на команды: \(error)")
//            }
//        }
//    }
//
//    func sendBlockCommand(for childID: String) {
//        Task {
//            do {
//                _ = try await CloudKitManager.shared.sendCommand(name: "block_all_apps", to: childID)
////                print("✅ Команда блокировки отправлена: \(recordID)")
//            } catch {
//                print("🚨 Ошибка отправки block команды: \(error)")
//            }
//        }
//    }
//
//    func sendUnblockCommand(for childID: String) {
//        Task {
//            do {
//                _ = try await CloudKitManager.shared.sendCommand(name: "unblock_all_apps", to: childID)
////                print("✅ Команда разблокировки отправлена: \(recordID)")
//            } catch {
//                print("🚨 Ошибка отправки unblock команды: \(error)")
//            }
//        }
//    }
//
////    func getActiveCommands(for childID: String) -> [CommandStatus] {
////        return CloudKitManager.shared.pendingCommands.values.filter {
////            $0.targetChildID == childID &&
////            ($0.status == .pending || $0.status == .delivered)
////        }
////    }
//
//    func selectRole(_ role: MemberType) {
//        let roleToSave: UserRole = (role == .parent) ? .parent : .child
//        saveUserRole(roleToSave) // Сохраняем выбранную роль
//
//        // Для обеих ролей мы просто сохраняем выбор.
//        // Дальнейшие действия (запрос разрешений) будут инициированы из View.
//        print("Роль '\(roleToSave.rawValue)' выбрана. Ожидание запроса разрешений...")
//    }
//
//    func requestParentAuthorization() {
//        Task {
//            do {
//                try await center.requestAuthorization(for: .individual)
//            } catch {
//                print("Ошибка при запросе авторизации родителя: \(error)")
//                appState = .accessDenied
//            }
//        }
//    }
//
//    func requestChildAuthorization() {
//        Task {
//            do {
//                try await center.requestAuthorization(for: .child)
//            } catch {
//                print("Ошибка при запросе авторизации ребенка: \(error)")
//                appState = .accessDenied
//            }
//        }
//    }
//
//    private func handleAuthorizationChange(status: AuthorizationStatus) {
//        print("🔄 Изменение статуса авторизации: \(status)")
//
//        switch status {
//        case .approved:
//            if userRole == .parent {
//                // ПОСЛЕ ПОЛУЧЕНИЯ РАЗРЕШЕНИЙ, ПРОВЕРЯЕМ НАЛИЧИЕ ДЕТЕЙ
//                if children.isEmpty {
//                    print("✅ Разрешения для родителя получены, детей нет. Переход к добавлению.")
//                    appState = .parentAddChild
//                } else {
//                    print("✅ Разрешения для родителя получены, дети есть. Переход на Dashboard.")
//                    appState = .parentDashboard
//                }
//            } else if userRole == .child {
//                // Логика для ребенка остается без изменений
//                if isPaired {
//                    print("ℹ️ Ребенок уже привязан. Переход на Dashboard.")
//                    setupChildDevice()
//                    appState = .childDashboard
//                } else {
//                    print("ℹ️ Ребенок еще не привязан. Переход на Pairing.")
//                    appState = .childPairing
//                }
//            }
//        case .denied:
//            appState = .accessDenied
//        case .notDetermined:
//            // Если разрешения были сброшены, мы должны отправить пользователя
//            // на правильный начальный экран.
//            appState = .roleSelection // Снова на выбор роли
//        @unknown default:
//            break
//        }
//    }
//
//    func childDeviceDidPair() {
//        print("👶 Ребенок успешно привязан!")
//
//        savePairingStatus(true)
//        saveUserRole(.child)
//        setupChildDevice()
////        startDeviceActivityMonitoring()
//        // ЗАПУСКАЕМ НАШ ЦИКЛ ПРОВЕРОК
////        scheduleNextDeviceActivityCheck()
////
//        self.appState = .childDashboard
//    }
////
////    func startDeviceActivityMonitoring() {
////        let now = Date()
////        let startOfDay = Calendar.current.startOfDay(for: now)
////
////        let schedule = DeviceActivitySchedule(
////            intervalStart: Calendar.current.dateComponents([.hour, .minute, .second], from: startOfDay),
////            intervalEnd: Calendar.current.dateComponents([.hour, .minute, .second], from: startOfDay.addingTimeInterval(86399)),
////            repeats: true
////        )
////
////        let center = DeviceActivityCenter()
////        do {
////            try center.startMonitoring(dailyActivityName, during: schedule)
////            print("✅ Мониторинг активности успешно запущен.")
////        } catch {
////            print("🚨 Ошибка при запуске мониторинга активности: \(error)")
////        }
////    }
//}


//@MainActor
//class AuthenticationManager: ObservableObject {
//    static let shared = AuthenticationManager()
//    let store = ManagedSettingsStore()
//    @Published var appState: AppState = .authRequired
//    
//    // 3. Свойство для хранения токена
//    @Published var authToken: String?
//    
//    // Ключ для хранения токена в Keychain (безопасное хранилище)
//    private let authTokenStorageKey = "com.laborato.parent.authToken"
//    
//    @Published var isLoading = true // Добавляем индикатор загрузки
//    
//    let center = AuthorizationCenter.shared
//    private var cancellables = Set<AnyCancellable>()
//    @Published var myUserRecordID: String?
//    
//    @Published var children: [Child] = []
//    
//    @Published var userRole: UserRole = .unknown
//    @Published var isPaired: Bool = false
//    
//    let dailyActivityName = DeviceActivityName("daily")
//    
//    // Ключи для сохранения в UserDefaults
//    private let userRoleStorageKey = "app_user_role"
//    private let childrenStorageKey = "managed_children_list"
//    private let isPairedStorageKey = "app_is_paired_to_parent"
//    
//    // В AuthenticationManager.swift
//    
//    init() {
//        center.$authorizationStatus
//            .sink { [weak self] status in
//                self?.handleAuthorizationChange(status: status)
//            }
//            .store(in: &cancellables)
//        
//        Task {
//            await initializeAppState()
//        }
//    }
//    
//    /// Единая функция, которая определяет начальное состояние приложения.
//    private func initializeAppState() async {
//                print("🚀 Запуск асинхронной инициализации...")
//        
//                // ШАГ 1: ПРОВЕРКА АУТЕНТИФИКАЦИИ НА НАШЕМ СЕРВЕРЕ
//                await loadAuthToken()
//        
//                guard let token = self.authToken else {
//                    // Если токена нет, сразу на экран входа.
//                    await MainActor.run {
//                        self.appState = .authRequired
//                        self.isLoading = false
//                    }
//                    print("🛑 Инициализация завершена: Токен не найден, требуется вход.")
//                    return
//                }
//        
//                let isTokenValid = await APIManager.shared.validateToken(token)
//        
//                guard isTokenValid else {
//                    // Если токен есть, но он невалиден, тоже на экран входа.
//                    await MainActor.run {
//                        self.appState = .authRequired
//                        self.isLoading = false
//                    }
//                    print("🛑 Инициализация завершена: Токен невалиден, требуется вход.")
//                    return
//                }
//        
//                print("✅ Токен валиден.")
//        
//        // ШАГ 2: ПОЛЬЗОВАТЕЛЬ АУТЕНТИФИЦИРОВАН. ЗАГРУЖАЕМ ЕГО ДАННЫЕ И НАСТРОЙКИ.
//        
//        // Загружаем сохраненную роль, список детей и т.д.
//        // Выполняем это в одной группе, чтобы ускорить процесс.
//        //        await Task.detached {
//        // Мы можем выполнять загрузку из UserDefaults в фоновом потоке
//        self.loadUserRole()
//        self.loadPairingStatus()
//        self.loadChildren()
//        self.myUserRecordID = await CloudKitManager.shared.fetchUserRecordID()
//        
//        // Сохраняем ID для расширения, если это ребенок
//        if let id = self.myUserRecordID, self.userRole == .child {
//            UserDefaults(suiteName: "group.com.laborato.test.Parent")?.set(id, forKey: "myUserRecordID")
//        }
//        //        }.value // .value дожидается завершения
//        
//        
//        // ШАГ 3: ОПРЕДЕЛЯЕМ СЛЕДУЮЩИЙ ЭКРАН (старый метод `determineInitialState`)
//        
//        // Теперь, когда все данные загружены, вызываем логику определения UI
//        await determineNextScreen()
//    }
//    
//    
//    // Переименовываем `determineInitialState` для ясности
//    private func determineNextScreen() async {
//        print("🔍 Определяю следующий экран...")
//        
//        let currentAuthStatus = center.authorizationStatus
//        
//        await MainActor.run {
//            if userRole == .unknown {
//                // Если роль не выбрана (например, новый пользователь), отправляем на выбор роли.
//                appState = .roleSelection
//                isLoading = false
//                return
//            }
//            
//            // Эта логика остается почти такой же, как у вас и была
//            switch currentAuthStatus {
//            case .approved:
//                if userRole == .parent {
//                    // ЕСЛИ Я РОДИТЕЛЬ И У МЕНЯ НЕТ ДЕТЕЙ,
//                    // ТО Я ИДУ НА ЭКРАН ДОБАВЛЕНИЯ РЕБЕНКА.
//                    if children.isEmpty {
//                        print("ℹ️ Родитель авторизован, но детей нет. Переход к добавлению.")
//                        appState = .parentAddChild
//                    } else {
//                        // Если дети есть, иду на главный экран.
//                        print("ℹ️ Родитель авторизован, дети есть. Переход на Dashboard.")
//                        appState = .parentDashboard
//                    }
//                } else if userRole == .child {
//                    // Логика для ребенка остается той же
//                    if isPaired {
//                        appState = .childDashboard
//                        // Запускаем фоновые сервисы для ребенка
//                        setupChildDeviceSubscriptions() // Переименованный метод
//                        scheduleNextDeviceActivityCheck() // Запускаем цикл
//                    } else {
//                        appState = .childPairing
//                    }
//                }
//                
//            case .denied:
//                appState = .accessDenied
//                
//            case .notDetermined:
//                // ЕСЛИ РАЗРЕШЕНИЙ НЕТ,
//                // ОСТАЕМСЯ НА ЭКРАНЕ ВЫБОРА РОЛИ.
//                // Пользователь сам инициирует запрос.
//                appState = .roleSelection
//                
//            @unknown default:
//                appState = .roleSelection
//            }
//            
//            isLoading = false
//            print("✅ Начальное состояние установлено: \(appState)")
//        }
//    }
//    
//    /// Сохраняет токен в безопасное хранилище Keychain
//    func saveAuthToken(_ token: String) async {
//        // TODO: Реализовать сохранение в Keychain. Для простоты пока используем UserDefaults.
//        UserDefaults.standard.set(token, forKey: authTokenStorageKey)
//        await MainActor.run {
//            self.authToken = token
//        }
//    }
//    
//    /// Загружает токен из Keychain
//    func loadAuthToken() async {
//        // TODO: Реализовать загрузку из Keychain.
//        if let token = UserDefaults.standard.string(forKey: authTokenStorageKey) {
//            await MainActor.run {
//                self.authToken = token
//            }
//        }
//    }
//    
//    /// Выход из системы
//    func logout() async {
//        // TODO: Реализовать удаление из Keychain
//        UserDefaults.standard.removeObject(forKey: authTokenStorageKey)
//        await MainActor.run {
//            self.authToken = nil
//            // Сбрасываем все состояния
//            self.userRole = .unknown
//            self.isPaired = false
//            self.appState = .authRequired
//        }
//    }
//    
//    // --- ОБНОВЛЕНИЕ ЛОГИКИ ПОСЛЕ УСПЕШНОГО ВХОДА ---
//    
//    /// Этот метод должен быть вызван после успешной регистрации или входа
//    func userDidAuthenticate(token: String) {
//        Task {
//            // 1. Сохраняем полученный токен
//            await saveAuthToken(token)
//            
//            // 2. Запускаем флоу выбора роли и т.д.
//            // (Предполагаем, что после первого входа роль еще не выбрана)
//            await MainActor.run {
//                // Здесь можно запросить с сервера роль, если она уже была выбрана
//                // Для простоты, отправляем на выбор роли
//                self.appState = .roleSelection
//            }
//        }
//    }
//    
//    
//    // Остальные методы остаются без изменений...
//    private func loadPairingStatus() {
//        if userRole == .child {
//            self.isPaired = UserDefaults.standard.bool(forKey: isPairedStorageKey)
//            print("✅ Статус привязки ребенка загружен: \(self.isPaired)")
//        }
//    }
//    
//    private func savePairingStatus(_ paired: Bool) {
//        UserDefaults.standard.set(paired, forKey: isPairedStorageKey)
//        self.isPaired = paired
//        print("✅ Статус привязки ребенка сохранен: \(paired)")
//    }
//    
//    private func loadUserRole() {
//        if let data = UserDefaults.standard.data(forKey: userRoleStorageKey),
//           let role = try? JSONDecoder().decode(UserRole.self, from: data) {
//            self.userRole = role
//            print("✅ Роль загружена: \(role.rawValue)")
//        } else {
//            print("ℹ️ Сохраненная роль не найдена. Будет показан экран выбора роли.")
//        }
//    }
//    
//    private func saveUserRole(_ role: UserRole) {
//        if let data = try? JSONEncoder().encode(role) {
//            UserDefaults.standard.set(data, forKey: userRoleStorageKey)
//            self.userRole = role
//            print("✅ Роль сохранена: \(role.rawValue)")
//        }
//    }
//    
//    // Удаляем старый updateInitialAppState или делаем его приватным
//    private func updateInitialAppState() {
//        // Этот метод больше не используется напрямую
//    }
//    
//    // Остальные методы остаются без изменений...
//    func addChild(name: String, recordID: String) {
//        let newChild = Child(id: UUID(), name: name, recordID: recordID)
//        children.append(newChild)
//        saveChildren()
//    }
//    
//    private func saveChildren() {
//        if let encodedData = try? JSONEncoder().encode(children) {
//            UserDefaults.standard.set(encodedData, forKey: childrenStorageKey)
//        }
//    }
//    
//    private func loadChildren() {
//        if let savedData = UserDefaults.standard.data(forKey: childrenStorageKey),
//           let decodedChildren = try? JSONDecoder().decode([Child].self, from: savedData) {
//            self.children = decodedChildren
//        }
//    }
//    
//    func setupChildDeviceSubscriptions() {
//        guard let childID = self.myUserRecordID else { return }
//        Task {
//            try await CloudKitManager.shared.subscribeToCommands(for: childID)
//        }
//    }
//
//    
//    func sendBlockCommand(for childID: String) {
//        Task {
//            do {
//                _ = try await CloudKitManager.shared.sendCommand(name: "block_all_apps", to: childID)
//                //                print("✅ Команда блокировки отправлена: \(recordID)")
//            } catch {
//                print("🚨 Ошибка отправки block команды: \(error)")
//            }
//        }
//    }
//    
//    func sendUnblockCommand(for childID: String) {
//        Task {
//            do {
//                _ = try await CloudKitManager.shared.sendCommand(name: "unblock_all_apps", to: childID)
//                //                print("✅ Команда разблокировки отправлена: \(recordID)")
//            } catch {
//                print("🚨 Ошибка отправки unblock команды: \(error)")
//            }
//        }
//    }
//    
//    func selectRole(_ role: MemberType) {
//        let roleToSave: UserRole = (role == .parent) ? .parent : .child
//        saveUserRole(roleToSave) // Сохраняем выбранную роль
//        
//        // Для обеих ролей мы просто сохраняем выбор.
//        // Дальнейшие действия (запрос разрешений) будут инициированы из View.
//        print("Роль '\(roleToSave.rawValue)' выбрана. Ожидание запроса разрешений...")
//    }
//    
//    func requestParentAuthorization() {
//        Task {
//            do {
//                try await center.requestAuthorization(for: .individual)
//            } catch {
//                print("Ошибка при запросе авторизации родителя: \(error)")
//                appState = .accessDenied
//            }
//        }
//    }
//    
//    func requestChildAuthorization() {
//        Task {
//            do {
//                try await center.requestAuthorization(for: .child)
//            } catch {
//                print("Ошибка при запросе авторизации ребенка: \(error)")
//                appState = .accessDenied
//            }
//        }
//    }
//    
//    private func handleAuthorizationChange(status: AuthorizationStatus) {
//        print("🔄 Изменение статуса авторизации: \(status)")
//        
//        switch status {
//        case .approved:
//            if userRole == .parent {
//                // ПОСЛЕ ПОЛУЧЕНИЯ РАЗРЕШЕНИЙ, ПРОВЕРЯЕМ НАЛИЧИЕ ДЕТЕЙ
//                if children.isEmpty {
//                    print("✅ Разрешения для родителя получены, детей нет. Переход к добавлению.")
//                    appState = .parentAddChild
//                } else {
//                    print("✅ Разрешения для родителя получены, дети есть. Переход на Dashboard.")
//                    appState = .parentDashboard
//                }
//            } else if userRole == .child {
//                // Логика для ребенка остается без изменений
//                if isPaired {
//                    appState = .childDashboard
//                    // Запускаем фоновые сервисы для ребенка
//                    setupChildDeviceSubscriptions() // Переименованный метод
//                    scheduleNextDeviceActivityCheck() // Запускаем цикл
//                } else {
//                    print("ℹ️ Ребенок еще не привязан. Переход на Pairing.")
//                    appState = .childPairing
//                }
//            }
//        case .denied:
//            appState = .accessDenied
//        case .notDetermined:
//            // Если разрешения были сброшены, мы должны отправить пользователя
//            // на правильный начальный экран.
//            appState = .roleSelection // Снова на выбор роли
//        @unknown default:
//            break
//        }
//    }
//    
//    func childDeviceDidPair() {
//        print("👶 Ребенок успешно привязан!")
//        savePairingStatus(true)
//        saveUserRole(.child)
//        self.appState = .childDashboard
//    }
//}


import Foundation
import Combine

@MainActor
class AuthenticationService: ObservableObject {
    // Публикуем статус авторизации, чтобы StateManager мог на него реагировать
    @Published var isAuthenticated: Bool = false
    @Published var authToken: String?
    @Published var myUserRecordID: String?
    
    private let authTokenStorageKey = "com.laborato.parent.authToken"
    
    init() {
        // При инициализации пытаемся восстановить токен
        loadAuthToken()
    }
    
    /// 1. Проверка сессии (вызывается при старте приложения)
    func checkSession() async -> Bool {
        guard let token = authToken, !token.isEmpty else {
            print("AuthService: Токен отсутствует.")
            isAuthenticated = false
            return false
        }
        
        // Эмуляция проверки токена на сервере (замени на свой APIManager)
        // let isValid = await APIManager.shared.validateToken(token)
        let isValid = true // Пока заглушка
        
        if isValid {
            print("AuthService: Токен валиден.")
            // Здесь можно загрузить myUserRecordID с CloudKit
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
        // Первичная установка флага, но реальная проверка будет в checkSession
        self.isAuthenticated = (authToken != nil)
    }
}
