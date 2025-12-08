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
            }
        }
    }
    
    // Храним статус блокировки локально для UI
    @Published var blockStatuses: [String: Bool] = [:]
    
    // Индикатор загрузки для UI (спиннер на кнопке)
    @Published var isCommandInProgressForSelectedChild = false
    
    private var cancellables = Set<AnyCancellable>()
    
    var isSelectedChildBlocked: Bool {
        guard let child = selectedChild else { return false }
        return blockStatuses[child.recordID, default: false]
    }
    
    init(stateManager: AppStateManager, cloudKitManager: CloudKitManager) {
        self.stateManager = stateManager
        self.cloudKitManager = cloudKitManager
        
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
              let childID = userInfo["childID"] as? String,
              let recordID = userInfo["recordID"] as? CKRecord.ID
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
                
                Task {
                    await cloudKitManager.deleteCommand(recordID: recordID)
                }
            }
        }
    }
}
