//
//  CommandSyncService.swift
//  Parent
//
//  Created by Michail Shagovitov on 12.12.2025.
//

import Foundation
import CloudKit
import FamilyControls
import ManagedSettings

class CommandSyncService {
    static let shared = CommandSyncService()
    let store = ManagedSettingsStore()
        
    // Этот метод будем вызывать отовсюду
    func checkPendingCommands() async {
        print("🔄 Начинаем проверку ожидающих команд...")
        
        guard let childID = await CloudKitManager.shared.fetchUserRecordID() else { return }
        
        // Ищем команды со статусом 'pending'
        let predicate = NSPredicate(format: "targetChildID == %@ AND status == %@", childID, "pending")
        let query = CKQuery(recordType: "Command", predicate: predicate)
        
        do {
            let (matchResults, _) = try await CloudKitManager.shared.publicDatabase.records(matching: query)
            
            for (_, result) in matchResults {
                guard let record = try? result.get(),
                      let commandName = record["commandName"] as? String else { continue }
                
                print("🚀 Найдена невыполненная команда: \(commandName)")
                
                // 1. Выполняем локально
                
                await MainActor.run {
                    executeLocalCommand(commandName)
                }
                
                // 2. Обновляем статус в CloudKit (чтобы не выполнять повторно)
                try? await CloudKitManager.shared.updateCommandStatus(recordID: record.recordID, status: .executed)
            }
            
            if matchResults.isEmpty {
                print("✅ Новых команд нет.")
            }
            
        } catch {
            print("🚨 Ошибка при поиске команд: \(error.localizedDescription)")
        }
    }
    
    func executeLocalCommand(_ commandName: String) {
        print("🎬 DeviceControlService: Приступаю к выполнению: \(commandName)")
        
        switch commandName {
        case "block_all":
            // Блокируем все категории
            store.shield.applicationCategories = .all()
            // Если нужно блокировать и веб-домены:
            // store.shield.webDomains = .all()
            print("🛡 Блокировка ВКЛЮЧЕНА (все приложения)")
            
        case "unblock_all":
            // Снимаем блокировку
            store.shield.applicationCategories = nil
            store.shield.webDomains = nil
            print("🔓 Блокировка СНЯТА")
            
        default:
            print("⚠️ Получена неизвестная команда: \(commandName)")
        }
    }
}
