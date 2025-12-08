//
//  DeviceControlService.swift
//  Parent
//
//  Created by Михаил Шаговитов on 08.12.2025.
//

import Foundation
import ManagedSettings
import FamilyControls

class DeviceControlService {
    // Делаем синглтоном, чтобы легко вызывать из AppDelegate
    static let shared = DeviceControlService()
    
    // Хранилище настроек Screen Time
    private let store = ManagedSettingsStore()
    
    private init() {}
    
    /// Выполняет локальную логику блокировки
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
