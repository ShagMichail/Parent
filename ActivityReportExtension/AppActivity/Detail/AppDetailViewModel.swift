//
//  AppDetailViewModel.swift
//  Parent
//
//  Created by Michail Shagovitov on 17.12.2025.
//

import SwiftUI
import FamilyControls
import ManagedSettings
import DeviceActivity
import CloudKit

@MainActor
class AppDetailViewModel: ObservableObject {
    // Входные данные
    let detail: AppUsageDetail
    
    // Выходные данные для View
    @Published var isBlocked: Bool = false
    @Published var isProcessing: Bool = false // Для блокировки кнопок
    @Published var currentLimit: String? // Текст текущего лимита
    
    // Сервисы
    private let store = ManagedSettingsStore()
    private let center = DeviceActivityCenter()
    
    private var childRecordID: String?
    private let database = CKContainer(identifier: "iCloud.com.laborato.Parent").publicCloudDatabase // Укажите ваш контейнер
    
    init(detail: AppUsageDetail) {
        self.detail = detail
        
        // Загружаем ID ребенка из общего хранилища
        if let defaults = UserDefaults(suiteName: "group.com.laborato.test.Parent") { // Укажите имя вашей App Group
            self.childRecordID = defaults.string(forKey: "currentlySelectedChildID")
        }
        
        // В будущем здесь будет загрузка актуального статуса
        self.isBlocked = false
    }
    
    /// Загружает начальный статус (блокировку и лимит)
    //    func loadInitialStatus() {
    //        // Проверяем, заблокировано ли приложение в данный момент
    //        self.isBlocked = store.shield.applications?.contains(detail.token) ?? false
    //
    //        // Загружаем информацию о существующем лимите
    //        loadCurrentLimit()
    //    }
    
    /// Переключает блокировку для этого приложения
    //    func toggleBlock() {
    //        isProcessing = true
    //
    //        if isBlocked {
    //            store.shield.applications?.remove(detail.token)
    //        } else {
    //            if store.shield.applications == nil {
    //                store.shield.applications = [detail.token]
    //            } else {
    //                store.shield.applications?.insert(detail.token)
    //            }
    //        }
    //
    //        self.isBlocked.toggle()
    //        isProcessing = false
    //    }
    
    
    /// Устанавливает дневной лимит использования
    func setUsageLimit(duration: TimeInterval) {
        isProcessing = true
        let activityName = activityNameForLimit()
        
        // Отменяем предыдущий лимит
        center.stopMonitoring([activityName])
        
        // Если duration > 0, устанавливаем новый лимит
        if duration > 0 {
            let schedule = dailySchedule()
            let eventName = DeviceActivityEvent.Name("limit.threshold.\(String(describing: detail.application.bundleIdentifier))")
            let event = DeviceActivityEvent(
                applications: [detail.token],
                threshold: .init(second: Int(duration))
            )
            do {
                try center.startMonitoring(activityName, during: schedule, events: [eventName: event])
                print("✅ Установлен лимит \(duration) сек для \(String(describing: detail.application.bundleIdentifier))")
            } catch {
                print("🚨 Ошибка установки лимита: \(error)")
            }
        } else {
            print("✅ Лимит для \(String(describing: detail.application.bundleIdentifier)) снят.")
        }
        
        // Обновляем UI
        loadCurrentLimit()
        isProcessing = false
    }
    
    // --- Приватные хелперы ---
    
    private func activityNameForLimit() -> DeviceActivityName {
        return DeviceActivityName("limit.\(String(describing: detail.application.bundleIdentifier))")
    }
    
    private func dailySchedule() -> DeviceActivitySchedule {
        let calendar = Calendar.current
        
        // Начало: 00:00 (начало текущего дня)
        let startComponents = DateComponents(hour: 0, minute: 0)
        
        // Конец: 23:59:59 (последняя секунда текущего дня)
        let endComponents = DateComponents(hour: 23, minute: 59, second: 59)
        
        // Создаем расписание с этими компонентами
        return DeviceActivitySchedule(
            intervalStart: startComponents,
            intervalEnd: endComponents,
            repeats: true // `repeats: true` заставит систему перезапускать это расписание каждый день
        )
    }
    
    private func loadCurrentLimit() {
        let activityName = activityNameForLimit()
        let activities = center.activities
        
        if activities.contains(activityName) {
            let events = center.events(for: activityName)
            if let threshold = events.first?.value.threshold {
                let duration = TimeInterval(threshold.second ?? 0)
                self.currentLimit = formatLimitDuration(duration)
            }
        } else {
            self.currentLimit = nil
        }
    }
    
    private func formatLimitDuration(_ duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.allowedUnits = [.hour, .minute]
        return formatter.string(from: duration) ?? ""
    }
    
    //    func toggleBlockViaCloudKit() {
    //        guard let childID = childRecordID else {
    //            print("❌ Ошибка: не найден ID ребенка в AppGroup UserDefaults.")
    //            return
    //        }
    //
    //        isProcessing = true
    //        let newBlockStatus = !isBlocked
    //        let commandName = newBlockStatus ? "block_app_token" : "unblock_app_token"
    ////        let payload: [String: Any] = ["token": detail.token]
    //        do {
    //            // 1. Кодируем сам ApplicationToken в Data с помощью JSONEncoder
    //            let tokenData = try JSONEncoder().encode(detail.token)
    //
    //            // 2. Кладем в payload уже готовые данные (Data)
    //            let payload: [String: Any] = ["tokenData": tokenData]
    //            Task {
    //                do {
    //                    // ✅ ИЗМЕНЕНИЕ 2: Вызываем локальную функцию отправки
    //                    try await sendCommand(name: commandName, to: childID, payload: payload)
    //                    self.isBlocked = newBlockStatus
    //                } catch {
    //                    print("❌ Ошибка отправки команды из расширения: \(error)")
    //                }
    //                self.isProcessing = false
    //            }
    //        } catch {
    //            print("❌ Ошибка кодирования токена: \(error)")
    //            isProcessing = false
    //        }
    //    }
    //
    //    private func sendCommand(name: String, to childID: String, payload: [String: Any]? = nil) async throws {
    //        let record = CKRecord(recordType: "Command")
    //        record["commandName"] = name as CKRecordValue
    //        record["targetChildID"] = childID as CKRecordValue
    //        record["status"] = "pending" as CKRecordValue
    //        record["createdAt"] = Date() as CKRecordValue
    //
    //        if let payload = payload {
    //            // `payload` - это уже словарь `[String: Any]`, где под ключом "tokenData" лежат данные типа Data.
    //            // NSKeyedArchiver УМЕЕТ работать со словарями, содержащими базовые типы и Data.
    //            let data = try NSKeyedArchiver.archivedData(withRootObject: payload, requiringSecureCoding: false)
    //            record["payload"] = data as CKRecordValue
    //        }
    //        try await database.save(record)
    //        print("✅ Command '\(name)' sent from extension to \(childID)")
    //    }
    //}
}
