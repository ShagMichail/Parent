//
//  WebBlockViewModel.swift
//  Parent
//
//  Created by Michail Shagovitov on 22.12.2025.
//

import SwiftUI
import Combine

@MainActor
class WebBlockViewModel: ObservableObject {
    enum SavingState {
        case idle, saving, success, error(String)
    }
    
    @Published var blocks: [WebBlock] = []
    private var originalBlocks: [WebBlock] = []
    
    @Published var savingState: SavingState = .idle
    @Published var showAlert = false
    var alertTitle: String = ""
    var alertMessage: String = ""
    
    @Published var isLoadingInitialBlocks = false
    
    @Published var selectedBlockForActions: WebBlock? = nil
    
    var child: Child?
    
    // Вычисляемое свойство для активации кнопки "Готово"
    var hasChanges: Bool {
        Set(blocks) != Set(originalBlocks)
    }

    /// Загрузка существующих блокировок при открытии экрана
    func loadInitialBlocks() {
        guard let childID = child?.recordID else { return }
        
        isLoadingInitialBlocks = true
        Task {
            do {
                let loadedBlocks = try await CloudKitManager.shared.fetchWebBlocks(for: childID)
                self.blocks = loadedBlocks
                self.originalBlocks = loadedBlocks // Сохраняем "снимок"
            } catch {
                print("❌ Ошибка загрузки блокировок сайтов: \(error)")
                // Показать ошибку пользователю
            }
            isLoadingInitialBlocks = false
        }
    }
    
    /// Сохранение изменений в CloudKit
    func saveBlocks() {
        guard let childID = child?.recordID else { return }
        guard hasChanges else { return }
        
        savingState = .saving
        Task {
            do {
                try await CloudKitManager.shared.syncWebBlocks(blocks, for: childID)
                // Отправляем "сигнал"
                 try await CloudKitManager.shared.triggerWebBlocksUpdateSignal(for: childID)
                
                self.originalBlocks = self.blocks // Обновляем "снимок"
                self.savingState = .success
                self.alertTitle = String(localized: "Successfully")
                self.alertMessage = String(localized: "The site blocking settings are saved.")
                self.showAlert = true
            } catch {
                self.savingState = .error(error.localizedDescription)
                self.alertTitle = String(localized: "Error")
                self.alertMessage = String(localized: "Couldn't save settings.")
                self.showAlert = true
            }
        }
    }

    /// Добавляет новый домен в список
    func addDomain(_ domain: String) {
        let cleanedDomain = domain.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard isValidDomain(cleanedDomain), !blocks.contains(where: { $0.domain == cleanedDomain }) else {
            // Можно показать ошибку, если домен некорректен
            return
        }
        blocks.append(WebBlock(domain: cleanedDomain))
    }
    
    /// Удаляет домен
    func deleteBlock(_ blockToDelete: WebBlock) {
        blocks.removeAll { $0.id == blockToDelete.id }
    }
    
    /// Простая проверка валидности домена
    private func isValidDomain(_ domain: String) -> Bool {
        let domainRegex = #"^([a-zA-Z0-9-]{1,63}\.)+[a-zA-Z]{2,63}$"#
        let domainPredicate = NSPredicate(format: "SELF MATCHES %@", domainRegex)
        return domainPredicate.evaluate(with: domain)
    }
}
