//
//  AppLimitsViewModel.swift
//  Parent
//
//  Created by Michail Shagovitov on 19.12.2025.
//

import SwiftUI
import FamilyControls
import ManagedSettings

@MainActor
class AppLimitsViewModel: ObservableObject {
    enum SavingState: Equatable {
        case idle // Ничего не происходит
        case saving // Идет сохранение
        case success // Успешно сохранено
        case error(String) // Произошла ошибка с сообщением
    }
    
    @Published var limits: [AppLimit] = []
    
    // `selection` теперь используется только для получения новых приложений из пикера
    @Published var selection = FamilyActivitySelection()
    
    @Published var savingState: SavingState = .idle
    @Published var showAlert = false
    @Published var isLoadingInitialLimits = true
    var alertTitle: String = ""
    var alertMessage: String = ""
    
    var child: Child?
    
    // Храним "снимок" состояния, загруженного с сервера
    private var originalLimits: [AppLimit] = []
    
    // Вычисляемое свойство, которое проверяет наличие изменений
    var hasChanges: Bool {
        return Set(limits) != Set(originalLimits)
    }
    
    func loadInitialLimits() {
        guard let childID = child?.recordID else {
            isLoadingInitialLimits = false
            return
        }
        
        isLoadingInitialLimits = true
        
        Task {
            do {
                // 1. Вызываем новую функцию CloudKitManager
                let loadedLimits = try await CloudKitManager.shared.fetchAppLimits(for: childID)
                
                // 2. Обновляем наш локальный массив лимитов
                self.limits = loadedLimits
                self.originalLimits = loadedLimits
                // 3. Синхронизируем `selection`
                // Мы говорим FamilyActivityPicker, какие галочки нужно проставить
                // 1. Создаем пустой объект selection
                var newSelection = FamilyActivitySelection()
                
                // 2. Получаем все токены из загруженных лимитов
                let tokensToSelect = loadedLimits.map { $0.token }
                
                // 3. Добавляем их в selection
                newSelection.applicationTokens = Set(tokensToSelect)
                
                // 4. Присваиваем результат нашему @Published свойству
                self.selection = newSelection
                
            } catch {
                print("❌ Ошибка при загрузке начальных лимитов: \(error.localizedDescription)")
                // В случае ошибки оставляем списки пустыми
                self.limits = []
                self.selection = FamilyActivitySelection()
            }
            
            // В любом случае убираем индикатор загрузки
            isLoadingInitialLimits = false
        }
    }
    
    func processNewSelection() {
        for token in selection.applicationTokens {
            // Добавляем новое приложение в наш список, только если его там еще нет
            if !limits.contains(where: { $0.token == token }) {
                // Устанавливаем лимит по умолчанию (например, 1 час)
                let newLimit = AppLimit(token: token, time: 3600)
                limits.append(newLimit)
            }
        }
    }
    
    func saveLimits() {
        guard let childID = child?.recordID else { return }
        guard savingState != .saving else { return }
        
        print("▶️ Начинаем сохранение \(limits.count) лимитов для ребенка: \(childID)")
        savingState = .saving
        
        Task {
            do {
                // Передаем весь массив `limits` в CloudKitManager
                try await CloudKitManager.shared.saveAppLimits(limits, for: childID)
                try await CloudKitManager.shared.triggerLimitsUpdateSignal(for: childID)
                
                self.originalLimits = self.limits
                print("✅ Все лимиты успешно сохранены в CloudKit.")
                self.savingState = .success
                self.alertTitle = String(localized: "Successfully")
                self.alertMessage = String(localized: "The new limits for applications have been maintained.")
                self.showAlert = true
                
            } catch {
                print("🛑 КРИТИЧЕСКАЯ ОШИБКА при сохранении лимитов: \(error.localizedDescription)")
                self.savingState = .error(error.localizedDescription)
                self.alertTitle = String(localized: "Error")
                self.alertMessage = String(localized: "Couldn't save the limits.")
                self.showAlert = true
            }
        }
    }
    
    // Полностью переписанная функция
    func syncLimitsWithSelection() {
        let currentSelectionTokens = selection.applicationTokens
        
        limits.removeAll { limit in
            !currentSelectionTokens.contains(limit.token)
        }
        
        for token in currentSelectionTokens {
            if !limits.contains(where: { $0.token == token }) {
                let newLimit = AppLimit(token: token, time: 3600) // Лимит по умолчанию 1 час
                limits.append(newLimit)
            }
        }
    }
}
