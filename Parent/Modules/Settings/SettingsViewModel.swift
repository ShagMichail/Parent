//
//  SettingsViewModel.swift
//  Parent
//
//  Created by Michail Shagovitov on 13.01.2026.
//

import SwiftUI
import Combine

@MainActor
class SettingsViewModel: ObservableObject {
    // Состояние для UI
    enum DeletionState {
        case idle // Ничего не происходит
        case loading // Идет удаление
        case success(Int) // Успешно удалено N подписок
        case error(String) // Произошла ошибка
    }
    
    @Published var deletionState: DeletionState = .idle
    private let cloudKitManager = CloudKitManager.shared
    
    /// Запускает процесс полного удаления всех подписок
    func deleteAllSubscriptions() {
//        guard case .loading == deletionState == false else { return }
        
        deletionState = .loading
        
        Task {
            do {
                let deletedCount = try await cloudKitManager.deleteAllSubscriptions()
                deletionState = .success(deletedCount)
            } catch {
                deletionState = .error(error.localizedDescription)
            }
        }
    }
}
