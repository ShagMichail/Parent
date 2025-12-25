//
//  AppBlockViewModel.swift
//  Parent
//
//  Created by Michail Shagovitov on 19.12.2025.
//

import SwiftUI
import FamilyControls
import ManagedSettings

@MainActor
class AppBlockViewModel: ObservableObject {
    enum SavingState: Equatable {
        case idle // Ничего не происходит
        case saving // Идет сохранение
        case success // Успешно сохранено
        case error(String) // Произошла ошибка с сообщением
    }
    
    @Published var blocks: [AppBlock] = []
    
    // `selection` теперь используется только для получения новых приложений из пикера
    @Published var selection = FamilyActivitySelection()
    
    @Published var savingState: SavingState = .idle
    @Published var showAlert = false
    @Published var isLoadingInitialBlocks = true
    var alertTitle: String = ""
    var alertMessage: String = ""
    
    var child: Child?
    
    // Храним "снимок" состояния, загруженного с сервера
    private var originalBlocks: [AppBlock] = []
    
    // Вычисляемое свойство, которое проверяет наличие изменений
    var hasChanges: Bool {
        return Set(blocks) != Set(originalBlocks)
    }
    
    func loadInitialBlocks() {
        guard let childID = child?.recordID else {
            isLoadingInitialBlocks = false
            return
        }
        
        isLoadingInitialBlocks = true
        
        Task {
            do {
                // 1. Вызываем новую функцию CloudKitManager
                let loadedBlocks = try await CloudKitManager.shared.fetchAppBlocks(for: childID)
                
                // 2. Обновляем наш локальный массив лимитов
                self.blocks = loadedBlocks
                self.originalBlocks = loadedBlocks
                // 3. Синхронизируем `selection`
                // Мы говорим FamilyActivityPicker, какие галочки нужно проставить
                // 1. Создаем пустой объект selection
                var newSelection = FamilyActivitySelection()
                
                // 2. Получаем все токены из загруженных лимитов
                let tokensToSelect = loadedBlocks.map { $0.token }
                
                // 3. Добавляем их в selection
                newSelection.applicationTokens = Set(tokensToSelect)
                
                // 4. Присваиваем результат нашему @Published свойству
                self.selection = newSelection
                
            } catch {
                print("❌ Ошибка при загрузке начальных блокировок: \(error.localizedDescription)")
                // В случае ошибки оставляем списки пустыми
                self.blocks = []
                self.selection = FamilyActivitySelection()
            }
            
            // В любом случае убираем индикатор загрузки
            isLoadingInitialBlocks = false
        }
    }
    
    func processNewSelection() {
        for token in selection.applicationTokens {
            // Добавляем новое приложение в наш список, только если его там еще нет
            if !blocks.contains(where: { $0.token == token }) {
                // Устанавливаем лимит по умолчанию (например, 1 час)
                let newBlock = AppBlock(token: token)
                blocks.append(newBlock)
            }
        }
    }
    
    func saveBlocks() {
        guard let childID = child?.recordID else { return }
        guard savingState != .saving else { return }
        
        print("▶️ Начинаем сохранение \(blocks.count) лимитов для ребенка: \(childID)")
        savingState = .saving
        
        Task {
            do {
                // Передаем весь массив `blocks` в CloudKitManager
                try await CloudKitManager.shared.saveAppBlocks(blocks, for: childID)
                try await CloudKitManager.shared.triggerBlocksUpdateSignal(for: childID)
                self.originalBlocks = self.blocks
                print("✅ Все блокировки успешно сохранены в CloudKit.")
                self.savingState = .success
                self.alertTitle = String(localized: "Successfully")
                self.alertMessage = String(localized: "The new app locks have been saved.")
                self.showAlert = true
                
            } catch {
                print("🛑 КРИТИЧЕСКАЯ ОШИБКА при сохранении блокировок: \(error.localizedDescription)")
                self.savingState = .error(error.localizedDescription)
                self.alertTitle = String(localized: "Error")
                self.alertMessage = String(localized: "The locks could not be saved.")
                self.showAlert = true
            }
        }
    }
    
    func syncBlocksWithSelection() {
        // Удаляем те лимиты, которых больше нет в selection
        let currentSelectionTokens = selection.applicationTokens
        
        // `removeAll` удалит из `blocks` все элементы, для которых условие истинно
        blocks.removeAll { block in
            !currentSelectionTokens.contains(block.token)
        }
        
        // Добавляем новые приложения, которых еще нет в списке
        for token in currentSelectionTokens {
            if !blocks.contains(where: { $0.token == token }) {
                let newBlock = AppBlock(token: token) // Лимит по умолчанию 1 час
                blocks.append(newBlock)
            }
        }
    }
}
