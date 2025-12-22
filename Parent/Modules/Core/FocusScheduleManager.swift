//
//  FocusScheduleManager.swift
//  Parent
//
//  Created by Михаил Шаговитов on 08.12.2025.
//

import Foundation
import DeviceActivity
import ManagedSettings
import FamilyControls

// Расширение для уникальных имен активностей
extension DeviceActivityName {
    static func focusSchedule(_ id: UUID) -> DeviceActivityName {
        DeviceActivityName("focus_schedule_\(id.uuidString)")
    }
}

class FocusScheduleManager: ObservableObject {
    static let shared = FocusScheduleManager()
    
    @Published var schedules: [FocusSchedule] = [] {
        didSet {
            // При любом изменении массива сохраняем его в UserDefaults
            saveSchedulesToDefaults()
        }
    }
    
    private let center = DeviceActivityCenter()
    private let store = ManagedSettingsStore()
    
    // ⚠️ ВАЖНО: Убедись, что Group ID совпадает в Extension
    private let groupDefaults = UserDefaults(suiteName: "group.com.laborato.test.Parent")
    
    private var isChildDevice: Bool {
        // Ключ должен совпадать с тем, что в AppStateManager ("app_user_role")
        guard let data = UserDefaults.standard.data(forKey: "app_user_role"),
              let role = try? JSONDecoder().decode(UserRole.self, from: data) else {
            return false
        }
        return role == .child
    }
    
    init() {
        // При запуске загружаем сохраненные расписания
        loadSchedules()
    }
    
    // MARK: - User Actions
    
    func addSchedule(_ schedule: FocusSchedule) {
        schedules.append(schedule)
        startMonitoring(for: schedule) // Сразу запускаем
    }
    
    func toggleSchedule(_ schedule: FocusSchedule) {
        guard let index = schedules.firstIndex(where: { $0.id == schedule.id }) else { return }
        
        // Переключаем статус
        schedules[index].isEnabled.toggle()
        let updatedSchedule = schedules[index]
        
        if updatedSchedule.isEnabled {
            // ВКЛЮЧИЛИ: Запускаем мониторинг
            startMonitoring(for: updatedSchedule)
            
            // Опционально: Проверяем, не попадает ли текущее время в интервал,
            // чтобы применить блокировку мгновенно, не дожидаясь границы времени.
            checkIfShouldBlockImmediately(schedule: updatedSchedule)
        } else {
            // ВЫКЛЮЧИЛИ: Останавливаем мониторинг
            stopMonitoring(for: updatedSchedule)
            
            // ⚠️ ВАЖНО: Если расписание было активно, снимаем щит прямо сейчас
            // (В более сложной версии нужно проверять, нет ли других активных расписаний)
            store.shield.applicationCategories = nil
            store.shield.webDomainCategories = nil
            print("🔓 Тогл выключен: принудительное снятие блокировки")
        }
    }
    
    func updateSchedule(_ schedule: FocusSchedule) {
        if let index = schedules.firstIndex(where: { $0.id == schedule.id }) {
            // Сначала останавливаем старое (на всякий случай)
            stopMonitoring(for: schedules[index])
            
            // Обновляем данные
            schedules[index] = schedule
            
            // Если оно включено, запускаем с новыми параметрами
            if schedule.isEnabled {
                startMonitoring(for: schedule)
            }
        }
    }
    
    func deleteSchedule(_ schedule: FocusSchedule) {
        // Останавливаем мониторинг
        stopMonitoring(for: schedule)
        // Удаляем из массива
        schedules.removeAll(where: { $0.id == schedule.id })
    }
    
    // MARK: - System Logic
    
    /// Запуск мониторинга для конкретного расписания
    private func startMonitoring(for schedule: FocusSchedule) {
        guard isChildDevice else { return }
        let activityName = DeviceActivityName.focusSchedule(schedule.id)
        let scheduleConfig = DeviceActivitySchedule(
            intervalStart: parseTime(schedule.startTime),
            intervalEnd: parseTime(schedule.endTime),
            repeats: true // Повторяем каждый день, Extension проверит дни недели
        )
        
        do {
            try center.startMonitoring(activityName, during: scheduleConfig)
            print("✅ Мониторинг ЗАПУЩЕН для: \(schedule.startTime) - \(schedule.endTime)")
        } catch {
            print("🚨 Ошибка запуска мониторинга: \(error)")
        }
    }
    
    /// Остановка мониторинга
    private func stopMonitoring(for schedule: FocusSchedule) {
        guard isChildDevice else { return }
        let activityName = DeviceActivityName.focusSchedule(schedule.id)
        center.stopMonitoring([activityName])
        print("🛑 Мониторинг ОСТАНОВЛЕН для ID: \(schedule.id)")
    }
    
    // MARK: - Helpers
    
    private func parseTime(_ date: Date) -> DateComponents {
        return Calendar.current.dateComponents([.hour, .minute], from: date)
    }
    
    private func saveSchedulesToDefaults() {
        if let data = try? JSONEncoder().encode(schedules) {
            groupDefaults?.set(data, forKey: "cached_focus_schedules")
        }
    }
    
    private func loadSchedules() {
        if let data = groupDefaults?.data(forKey: "cached_focus_schedules"),
           let loaded = try? JSONDecoder().decode([FocusSchedule].self, from: data) {
            self.schedules = loaded
        }
    }
    
    /// Проверка для мгновенной реакции при включении тогла
    private func checkIfShouldBlockImmediately(schedule: FocusSchedule) {
        // Если это родитель, выходим сразу
        guard isChildDevice else { return }
        // Твоя модель УЖЕ умеет это делать! Используем её метод.
        if schedule.isActiveNow() {
            print("⚡️ Тогл включен внутри активного интервала: Мгновенная блокировка!")
            store.shield.applicationCategories = .all()
            store.shield.webDomainCategories = .all()
        }
    }
    
    private func isDayMatching(_ daysString: String) -> Bool {
        // Упрощенная проверка для мгновенной реакции
        // Лучше вынести логику проверки дней в общий утилитный класс, доступный и App и Extension
        if daysString.contains("Каждый день") { return true }
        let weekday = Calendar.current.component(.weekday, from: Date())
        if daysString.contains("ПН–ПТ") && (2...6).contains(weekday) { return true }
        if daysString.contains("СБ–ВС") && (weekday == 1 || weekday == 7) { return true }
        return false
    }
    
    func syncFromCloudKit() async {
        // Получаем ID ребенка (он должен быть сохранен где-то, например в UserDef)
        guard let childID = await CloudKitManager.shared.fetchUserRecordID() else { return }
        
        do {
            print("🔄 [Child] Синхронизация расписаний с облаком...")
            // 1. Скачиваем актуальный список из CloudKit
            let cloudSchedules = try await CloudKitManager.shared.fetchSchedules(for: childID)
            
            await MainActor.run {
                // 2. Обновляем локальный массив
                self.schedules = cloudSchedules
                // 3. Сохраняем в AppGroup и перезапускаем мониторинг (это делает didSet или вызови явно)
                self.syncWithDeviceActivity()
            }
            print("✅ [Child] Расписания обновлены. Всего: \(cloudSchedules.count)")
            
        } catch {
            print("🚨 Ошибка синхронизации расписаний: \(error)")
        }
    }
    
    private func syncWithDeviceActivity() {
        print("⚙️ Синхронизация всех активностей с системой...")
        saveSchedulesToDefaults() // На всякий случай обновляем Extension
        
        // 🛑 ГЛАВНОЕ ИСПРАВЛЕНИЕ:
        // Если это не ребенок, мы НЕ трогаем DeviceActivityCenter
        guard isChildDevice else {
            print("👨‍👩‍👧 Устройство Родителя: Пропускаем запуск мониторинга ScreenTime.")
            return
        }
        
        print("⚙️ Синхронизация всех активностей с системой...")
        
        for schedule in schedules {
            if schedule.isEnabled {
                startMonitoring(for: schedule)
            } else {
                stopMonitoring(for: schedule)
            }
        }
    }
    
    @MainActor
    func syncWithDeviceActivityFromCache() {
        loadSchedules()
        
        syncWithDeviceActivity()
        
        // --- ДОПОЛНИТЕЛЬНАЯ ПРОВЕРКА ---
        // Yе должно ли какое-то из расписаний быть активным ПРЯМО СЕЙЧАС
        var shouldBeBlockedNow = false
        for schedule in schedules {
            if schedule.isActiveNow() {
                shouldBeBlockedNow = true
                break
            }
        }
        
        if shouldBeBlockedNow {
            print("⚡️ [Manager] Синхронизация показала, что блокировка должна быть активна сейчас. Включаем.")
            store.shield.applicationCategories = .all()
            store.shield.webDomainCategories = .all()
        } else {
            // Опционально: если ни одно расписание не активно, можно снять блокировку
            // print("[Manager] Ни одно расписание не активно. Снимаем блокировку.")
            store.shield.applicationCategories = nil
            store.shield.webDomainCategories = nil
        }
    }
}
