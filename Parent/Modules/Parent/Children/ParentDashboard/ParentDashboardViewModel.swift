//
//  ParentDashboardViewModel.swift
//  Parent
//
//  Created by Михаил Шаговитов on 04.12.2025.
//

import SwiftUI
import Combine
import CloudKit

@MainActor
class ParentDashboardViewModel: ObservableObject {
    @Published var children: [Child] = []
    @Published var selectedChild: Child? {
        didSet {
            if let child = selectedChild {
                setupSubscription(for: child)
                refreshChildStatus()
                saveSelectedChildID()
            }
        }
    }
    @Published var blockStatuses: [String: Bool] = [:]
    @Published var focusStatuses: [String: Bool] = [:]
    @Published var childStreetNames: [String: String] = [:]
    @Published var batteryStatuses: [String: (level: Float, state: String)] = [:]
    @Published var onlineStatuses: [String: OnlineStatus] = [:]
    @Published var isCommandInProgressForSelectedChild = false
    @Published var isLoadingInitialState = false
    
    private var cancellables = Set<AnyCancellable>()
    private var stateManager: AppStateManager
    private var cloudKitManager: CloudKitManager
    private let blockStatusCacheKey = "cached_block_statuses"
    private let focusStatusCacheKey = "cached_focus_statuses"
    
    var isSelectedChildBlocked: Bool {
        guard let child = selectedChild else { return false }
        return blockStatuses[child.recordID, default: false]
    }
    var isFocusActiveForSelectedChild: Bool {
        guard let child = selectedChild else { return false }
        return focusStatuses[child.recordID, default: false]
    }
    
    init(stateManager: AppStateManager, cloudKitManager: CloudKitManager) {
        self.stateManager = stateManager
        self.cloudKitManager = cloudKitManager
        loadCachedStatuses()
        // Синхронизация списка детей
        stateManager.$children
            .sink { [weak self] updatedChildren in
                self?.children = updatedChildren
                if self?.selectedChild == nil {
                    self?.selectedChild = updatedChildren.first
                }
            }
            .store(in: &cancellables)
        
        // Слушаем уведомления от AppDelegate
        NotificationCenter.default.publisher(for: .commandUpdated)
            .sink { [weak self] notification in
                self?.handleCommandUpdate(notification)
            }
            .store(in: &cancellables)
    }
    
    
    // MARK: - Public Method
    
    /// Загружает последнюю команду и выставляет UI
    func refreshChildStatus() {
        
        guard let child = selectedChild else { return }
        isLoadingInitialState = true
        
        Task {
            do {
                if let lastRecord = try await cloudKitManager.fetchLatestBlockCommand(for: child.recordID) {
                    
                    let commandName = lastRecord["commandName"] as? String ?? ""
                    let statusRaw = lastRecord["status"] as? String ?? ""
                    
                    // Обновляем UI в главном потоке
                    await MainActor.run {
                        // 1. Определяем статус блокировки на основе имени ПОСЛЕДНЕЙ команды
                        if commandName == "block_all" {
                            self.blockStatuses[child.recordID] = true
                        } else {
                            self.blockStatuses[child.recordID] = false
                        }
                        
                        // 2. Если статус pending, значит процесс еще идет -> крутим спиннер
                        if statusRaw == CommandStatus.pending.rawValue {
                            self.isCommandInProgressForSelectedChild = true
                        } else {
                            self.isCommandInProgressForSelectedChild = false
                        }
                    }
                } else {
                    // Если команд нет вообще, считаем, что ребенок разблокирован
                    await MainActor.run {
                        self.blockStatuses[child.recordID] = false
                        self.isCommandInProgressForSelectedChild = false
                    }
                }
            } catch {
                print("Error fetching child status: \(error)")
            }
            
            await checkFocusStatus(for: child)
            await updateChildDetails(for: child)
            
            self.saveCachedStatuses()
            
            await MainActor.run {
                self.isLoadingInitialState = false
            }
        }
    }
    
    func getStreetName(for childID: String) -> String {
        // Возвращаем название улицы или текст-заглушку, пока данные грузятся
        return childStreetNames[childID, default: String(localized: "Location Update...")]
    }
    
    func getBatteryColor(for childID: String) -> Color {
        guard let status = batteryStatuses[childID] else { return .gray }
        
        if status.state == "charging" || status.state == "full" {
            return .chartStart
        }
        
        if status.level <= 0.2 { return .warningStart }
        if status.level <= 0.5 { return .questionStart }
        return .chartStart
    }
    
    func getBatteryText(for childID: String) -> String {
        guard let status = batteryStatuses[childID] else { return "--%" }
        return "\(Int(status.level * 100))%"
    }
    
    /// Основное действие по кнопке
    func toggleBlock() {
        guard let child = selectedChild else { return }
        guard !isCommandInProgressForSelectedChild else { return }
        
        isCommandInProgressForSelectedChild = true
        
        let currentStatus = isSelectedChildBlocked
        let commandName = currentStatus ? "unblock_all" : "block_all"
        
        Task {
            do {
                try await cloudKitManager.sendCommand(name: commandName, to: child.recordID)
            } catch {
                print("Error sending command: \(error)")
                isCommandInProgressForSelectedChild = false
            }
        }
    }
    
    func getOnlineStatus(for childID: String) -> (text: String, color: Color) {
        let status = onlineStatuses[childID, default: .unknown]
        return (status.text, status.color)
    }
    
    
    // MARK: - Private Method
    
    // Mетод получения батареи и локации
    private func updateChildDetails(for child: Child) async {
        do {
            guard let status = try await cloudKitManager.fetchDeviceStatus(for: child.recordID) else {
                await MainActor.run {
                    self.childStreetNames[child.recordID] = String(localized: "Location unknown")
                }
                await MainActor.run {
                    self.onlineStatuses[child.recordID] = .unknown
                }
                return
            }
            
            let onlineStatus = determineOnlineStatus(from: status.lastSeen)
            
            await MainActor.run {
                self.batteryStatuses[child.recordID] = (status.batteryLevel, status.batteryState)
                self.onlineStatuses[child.recordID] = onlineStatus
            }
            
            guard let location = status.location else {
                await MainActor.run {
                    self.childStreetNames[child.recordID] = String(localized: "Coordinates are not defined")
                }
                return
            }
            
            let geocoder = CLGeocoder()
            
            do {
                if let placemark = try await geocoder.reverseGeocodeLocation(location).first {
                    let addressString = self.formatAddress(from: placemark)
                    await MainActor.run {
                        self.childStreetNames[child.recordID] = addressString
                        print("📍 Адрес для \(child.name): \(addressString)")
                    }
                }
            } catch {
                print("❌ Ошибка геокодирования: \(error.localizedDescription)")
                await MainActor.run {
                    self.childStreetNames[child.recordID] = String(localized: "Couldn't determine the address")
                }
            }
            
        } catch {
            print("❌ Ошибка загрузки статуса для \(child.name): \(error)")
            await MainActor.run { self.onlineStatuses[child.recordID] = .offline }
        }
    }
    
    private func determineOnlineStatus(from lastSeen: Date) -> OnlineStatus {
        let timeSinceLastSeen = Date().timeIntervalSince(lastSeen)
        
        // Если прошло меньше 5 минут (300 секунд)
        if timeSinceLastSeen < 300 {
            return .online
        }
        // Если прошло меньше часа (3600 секунд)
        else if timeSinceLastSeen < 3600 {
            return .recent(lastSeen: lastSeen)
        }
        // Если прошло больше часа
        else {
            return .offline
        }
    }
    
    private func checkFocusStatus(for child: Child) async {
        do {
            let schedules = try await cloudKitManager.fetchSchedules(for: child.recordID)
            
            let hasActiveSchedule = schedules.contains { $0.isEnabled }
            
            await MainActor.run {
                self.focusStatuses[child.recordID] = hasActiveSchedule
            }
        } catch {
            print("Error fetching focus schedules: \(error)")
        }
    }
    
    private func setupSubscription(for child: Child) {
        Task {
            do {
                try await cloudKitManager.subscribeToCommandUpdates(for: child.recordID)
            } catch {
                print("Error subscribing to child updates: \(error)")
            }
        }
    }
    
    /// Обработка ответа от ребенка
    private func handleCommandUpdate(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let statusRaw = userInfo["status"] as? String,
              let commandName = userInfo["commandName"] as? String,
              let childID = userInfo["childID"] as? String
        else { return }

        // Проверяем, касается ли это текущего выбранного ребенка
        if let selected = selectedChild, selected.recordID == childID {
            
            if statusRaw == CommandStatus.executed.rawValue {
                isCommandInProgressForSelectedChild = false
                if commandName == "block_all" {
                    blockStatuses[childID] = true
                } else if commandName == "unblock_all" {
                    blockStatuses[childID] = false
                }
                self.saveCachedStatuses()
            }
        }
    }
    
    private func loadCachedStatuses() {
        if let data = UserDefaults.standard.data(forKey: blockStatusCacheKey),
           let cachedStatuses = try? JSONDecoder().decode([String: Bool].self, from: data) {
            self.blockStatuses = cachedStatuses
        }
        
        if let focusData = UserDefaults.standard.data(forKey: focusStatusCacheKey),
           let cachedFocus = try? JSONDecoder().decode([String: Bool].self, from: focusData) {
            self.focusStatuses = cachedFocus
        }
    }
    
    private func saveCachedStatuses() {
        if let data = try? JSONEncoder().encode(blockStatuses) {
            UserDefaults.standard.set(data, forKey: blockStatusCacheKey)
        }
        
        if let focusData = try? JSONEncoder().encode(focusStatuses) {
            UserDefaults.standard.set(focusData, forKey: focusStatusCacheKey)
        }
    }
    
    private func formatAddress(from placemark: CLPlacemark) -> String {
        var addressParts: [String] = []
        
        // `thoroughfare` - это улица
        if let street = placemark.thoroughfare {
            addressParts.append(street)
            // `subThoroughfare` - это номер дома
            if let houseNumber = placemark.subThoroughfare {
                addressParts.append(houseNumber)
            }
        } else if let poi = placemark.name {
            // Если улицы нет (например, это парк или ТЦ), используем название места
            addressParts.append(poi)
        } else {
            // Если совсем ничего нет, возвращаем город
            return placemark.locality ?? String(localized: "Unknown location")
        }
        
        return addressParts.joined(separator: ", ")
    }
    
    private func saveSelectedChildID() {
        if let defaults = UserDefaults(suiteName: "group.com.laborato.test.Parent") {
            defaults.set(selectedChild?.recordID, forKey: "currentlySelectedChildID")
        }
    }
}
