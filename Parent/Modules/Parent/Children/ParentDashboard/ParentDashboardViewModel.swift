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
    private var stateManager: AppStateManager
    private var cloudKitManager: CloudKitManager
    @Published var children: [Child] = []
    @Published var selectedChild: Child? {
        didSet {
            if let child = selectedChild {
                setupSubscription(for: child)
                refreshChildStatus()
            }
        }
    }
    
    // Храним статус блокировки локально для UI
    @Published var blockStatuses: [String: Bool] = [:]
    // Храним: [ChildID : Есть ли активные расписания]
    @Published var focusStatuses: [String: Bool] = [:]
    
    @Published var batteryStatuses: [String: (level: Float, state: String)] = [:]
    
    // Индикатор загрузки для UI (спиннер на кнопке)
    @Published var isCommandInProgressForSelectedChild = false
    @Published var isLoadingInitialState = false
    
    private var cancellables = Set<AnyCancellable>()
    
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
        
        // Слушаем уведомления от AppDelegate (когда приходит пуш от CloudKit)
        NotificationCenter.default.publisher(for: .commandUpdated)
            .sink { [weak self] notification in
                self?.handleCommandUpdate(notification)
            }
            .store(in: &cancellables)
    }
    
    /// Загружает последнюю команду и выставляет UI
    func refreshChildStatus() {
        
        guard let child = selectedChild else { return }
        isLoadingInitialState = true
        
        Task {
            do {
                if let lastRecord = try await cloudKitManager.fetchLatestCommand(for: child.recordID) {
                    
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
            await updateBatteryForChild(child)
            
            self.saveCachedStatuses()
            
            await MainActor.run {
                self.isLoadingInitialState = false
            }
        }
    }
    
    // Новый метод получения батареи
    private func updateBatteryForChild(_ child: Child) async {
        do {
            // Теперь метод возвращает кортеж из 4 элементов
            if let status = try await cloudKitManager.fetchDeviceStatus(for: child.recordID) {
                await MainActor.run {
                    // Обновляем батарею
                    self.batteryStatuses[child.recordID] = (status.batteryLevel, status.batteryState)
                    
                    // Тут же можно сохранить локацию, если у вас есть для этого свойство
                    // self.childLocations[child.recordID] = status.location
                }
            }
        } catch {
            print("Error fetching battery: \(error)")
        }
    }
    
    // Хелпер для View (получение цвета)
    func getBatteryColor(for childID: String) -> Color {
        guard let status = batteryStatuses[childID] else { return .gray }
        
        if status.state == "charging" || status.state == "full" {
            return .green
        }
        
        if status.level <= 0.2 { return .red }
        if status.level <= 0.5 { return .orange }
        return .green
    }
    
    // Хелпер для текста
    func getBatteryText(for childID: String) -> String {
        guard let status = batteryStatuses[childID] else { return "--%" }
        return "\(Int(status.level * 100))"
    }
    
    private func checkFocusStatus(for child: Child) async {
        do {
            // Запрашиваем расписания из CloudKit
            let schedules = try await cloudKitManager.fetchSchedules(for: child.recordID)
            
            // Логика: Если есть хотя бы одно расписание, у которого isEnabled == true -> статус "Вкл"
            let hasActiveSchedule = schedules.contains { $0.isEnabled }
            
            await MainActor.run {
                self.focusStatuses[child.recordID] = hasActiveSchedule
            }
        } catch {
            print("Error fetching focus schedules: \(error)")
        }
    }
    
    /// Основное действие по кнопке
    func toggleBlock() {
        guard let child = selectedChild else { return }
        guard !isCommandInProgressForSelectedChild else { return } // Защита от дабл-клика
        
        isCommandInProgressForSelectedChild = true
        
        let currentStatus = isSelectedChildBlocked
        let commandName = currentStatus ? "unblock_all" : "block_all" // Инвертируем действие
        
        Task {
            do {
                // 1. Отправляем команду
                try await cloudKitManager.sendCommand(name: commandName, to: child.recordID)
                
                // В реальном приложении мы ждем пуш-уведомления об успехе,
                // но для UX можно оптимистично обновить UI или ждать (зависит от требований)
                // Пока оставим спиннер крутиться, пока не придет ответ.
                
            } catch {
                print("Error sending command: \(error)")
                isCommandInProgressForSelectedChild = false
            }
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
                // Команда выполнена успешно!
                isCommandInProgressForSelectedChild = false
                
                // Обновляем локальный стейт блокировки
                if commandName == "block_all" {
                    blockStatuses[childID] = true
                } else if commandName == "unblock_all" {
                    blockStatuses[childID] = false
                }
                self.saveCachedStatuses()
            }
        }
    }
    
    // 1. Метод для загрузки кеша (вызываем в init)
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
    
    // 2. Метод для сохранения кеша (вызываем при получении данных)
    private func saveCachedStatuses() {
        if let data = try? JSONEncoder().encode(blockStatuses) {
            UserDefaults.standard.set(data, forKey: blockStatusCacheKey)
        }
        
        if let focusData = try? JSONEncoder().encode(focusStatuses) {
            UserDefaults.standard.set(focusData, forKey: focusStatusCacheKey)
        }
    }
}
