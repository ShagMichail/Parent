//
//  ChildDashboardViewModel.swift
//  Parent
//
//  Created by Michail Shagovitov on 29.12.2025.
//

import SwiftUI
import Combine
import CloudKit

@MainActor
class ChildDashboardViewModel: ObservableObject {
    @Published var restrictions: [RestrictionItem] = []
    @Published var isLoading = false
    @Published var childName: String = "Пользователь"
    
    private let cloudKitManager = CloudKitManager.shared
    private let childNameStorageKey = "com.laborato.child.name"
    
    init() {
        loadChildName()
    }

    /// Главная функция для загрузки всех ограничений
    func fetchAllRestrictions() async {
        guard let childID = await CloudKitManager.shared.fetchUserRecordID() else {
            print("❌ ChildDashboard: Не удалось получить ID ребенка для загрузки ограничений.")
            return
        }
        
        isLoading = true
        restrictions = []
        
        Task {
            // Запускаем загрузку всех типов ограничений параллельно
            await withTaskGroup(of: Void.self) { group in
                group.addTask { await self.fetchLastBlockCommand(for: childID) }
                // 1. Загрузка блокировок приложений
                group.addTask { await self.fetchAppBlocks(for: childID) }
                // 2. Загрузка лимитов приложений
                group.addTask { await self.fetchAppLimits(for: childID) }
                // 3. Загрузка блокировок сайтов
                group.addTask { await self.fetchWebBlocks(for: childID) }
                // 4. Загрузка расписаний (фокусов)
                group.addTask { await self.fetchFocusSchedules(for: childID) }
            }
            
            isLoading = false
        }
    }
    
    private func loadChildName() {
        if let savedName = UserDefaults.standard.string(forKey: childNameStorageKey) {
            self.childName = savedName
        }
    }
    
    private func fetchAppBlocks(for childID: String) async {
        do {
            let blocks = try await cloudKitManager.fetchAppBlocks(for: childID)
            if !blocks.isEmpty {
                let item = RestrictionItem(
                    id: UUID().uuidString,
                    title: String(localized: "Blocked apps"),
                    description: String(localized: "The parent has restricted access to the apps:"),
                    iconName: "lock-command",
                    count: blocks.count
                )
                restrictions.append(item)
            }
        } catch { print("Ошибка загрузки блокировок: \(error)") }
    }
    
    private func fetchLastBlockCommand(for childID: String) async {
        do {
            let block = try await cloudKitManager.fetchLastBlockCommand(for: childID)
            if block != nil && block == "block_all" {
                let item = RestrictionItem(
                    id: UUID().uuidString,
                    title: String(localized: "The device is locked"),
                    description: String(localized: "The device is locked at the parent's command"),
                    iconName: "lock-command"
                )
                restrictions.append(item)
            }
        } catch { print("Ошибка загрузки состояния блокировки: \(error)") }
    }
    
    private func fetchAppLimits(for childID: String) async {
        do {
            let limits = try await cloudKitManager.fetchAppLimits(for: childID)
            if !limits.isEmpty {
                let item = RestrictionItem(
                    id: UUID().uuidString,
                    title: String(localized: "Time limits"),
                    description: String(localized: "There are daily limits for applications:"),
                    iconName: "timer-command",
                    count: limits.count
                )
                restrictions.append(item)
            }
        } catch { print("Ошибка загрузки лимитов: \(error)") }
    }

    private func fetchWebBlocks(for childID: String) async {
        do {
            let webBlocks = try await cloudKitManager.fetchWebBlocks(for: childID)
            if !webBlocks.isEmpty {
                let item = RestrictionItem(
                    id: UUID().uuidString,
                    title: String(localized: "Internet Restrictions"),
                    description: String(localized: "Access to websites is blocked:"),
                    iconName: "web-command",
                    count: webBlocks.count
                )
                restrictions.append(item)
            }
        } catch { print("Ошибка загрузки блокировок сайтов: \(error)") }
    }

    private func fetchFocusSchedules(for childID: String) async {
        do {
            let schedules = try await cloudKitManager.fetchSchedules(for: childID)
            let activeSchedules = schedules.filter { $0.isEnabled }
            if !activeSchedules.isEmpty {
                let item = RestrictionItem(
                    id: UUID().uuidString,
                    title: String(localized: "Focus modes"),
                    description: String(localized: "Set up schedules for concentration:"),
                    iconName: "focus-command",
                    count: activeSchedules.count
                )
                restrictions.append(item)
            }
        } catch { print("Ошибка загрузки расписаний: \(error)") }
    }
}
