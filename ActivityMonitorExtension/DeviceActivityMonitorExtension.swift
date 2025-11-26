//
//  DeviceActivityMonitorExtension.swift
//  ActivityMonitorExtension
//
//  Created by Михаил Шаговитов on 26.11.2025.
//

// ActivityMonitorExtension.swift
import DeviceActivity
import ManagedSettings
import Foundation

class ActivityMonitorExtension: DeviceActivityMonitor {
    let store = ManagedSettingsStore()
    
    // Добавляем доступ к общему хранилищу App Group
    let appGroupID = "group.com.laborato.test.Parent"
    var sharedUserDefaults: UserDefaults? {
        return UserDefaults(suiteName: appGroupID)
    }

    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        
        print("ActivityMonitorExtension: Интервал начался. Проверяю сохраненные правила.")
        
        // 1. ЗАГРУЖАЕМ ПРАВИЛО из общего хранилища, которое установило основное приложение.
        let shouldBlock = sharedUserDefaults?.bool(forKey: "shouldBlockAllApps") ?? false
        
        print("ActivityMonitorExtension: Текущее правило 'Блокировать все' = \(shouldBlock)")
        
        // 2. ПРИМЕНЯЕМ ИЛИ СНИМАЕМ БЛОКИРОВКУ в зависимости от правила.
        if shouldBlock {
            // Этот код будет вызван в фоне, даже если ваше основное приложение закрыто.
            store.shield.applicationCategories = .all()
            print("ActivityMonitorExtension: Ограничения ПРИМЕНЕНЫ согласно правилу.")
        } else {
            store.shield.applicationCategories = nil
            store.shield.webDomains = nil
            print("ActivityMonitorExtension: Ограничения СНЯТЫ согласно правилу.")
        }
    }

    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        print("ActivityMonitorExtension: Интервал закончился. Снимаю все ограничения.")
        // По окончании расписания (например, в полночь) можно снять все блокировки
        store.shield.applicationCategories = nil
        store.shield.webDomains = nil
        sharedUserDefaults?.set(false, forKey: "shouldBlockAllApps") // Сбрасываем правило
    }
}
