//
//  FocusScheduleManager.swift
//  Parent
//
//  Created by Михаил Шаговитов on 08.12.2025.
//

import Foundation

class FocusScheduleManager: ObservableObject {
    static let shared = FocusScheduleManager()
    
    @Published var schedules: [FocusSchedule] = []
    
    private let storageKey = "focusSchedules"
    
    init() {
        loadSchedules()
    }
    
    // Загрузка из UserDefaults
    private func loadSchedules() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([FocusSchedule].self, from: data) {
            self.schedules = decoded
        } else {
            // Если нет сохраненных данных, создаем пример
            self.schedules = createDefaultSchedules()
        }
    }
    
    // Сохранение в UserDefaults
    private func saveSchedules() {
        if let encoded = try? JSONEncoder().encode(schedules) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
            objectWillChange.send()
        }
    }
    
    // Создание примеров по умолчанию
    private func createDefaultSchedules() -> [FocusSchedule] {
        let calendar = Calendar.current
        
        let morningStart = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date()
        let morningEnd = calendar.date(bySettingHour: 11, minute: 30, second: 0, of: Date()) ?? Date()
        
        let eveningStart = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
        let eveningEnd = calendar.date(bySettingHour: 10, minute: 30, second: 0, of: Date()) ?? Date()
        
        return [
            FocusSchedule(
                startTime: morningStart,
                endTime: morningEnd,
                daysOfWeek: [.monday, .tuesday, .wednesday, .thursday, .friday],
                isEnabled: false
            ),
            FocusSchedule(
                startTime: eveningStart,
                endTime: eveningEnd,
                daysOfWeek: [.monday, .tuesday, .wednesday, .thursday, .friday],
                isEnabled: true
            )
        ]
    }
    
    // MARK: - Public Methods
    
    func addSchedule(_ schedule: FocusSchedule) {
        schedules.append(schedule)
        saveSchedules()
    }
    
    func updateSchedule(_ schedule: FocusSchedule) {
        if let index = schedules.firstIndex(where: { $0.id == schedule.id }) {
            schedules[index] = schedule
            saveSchedules()
        }
    }
    
    func deleteSchedule(_ schedule: FocusSchedule) {
        schedules.removeAll { $0.id == schedule.id }
        saveSchedules()
    }
    
    func toggleSchedule(_ schedule: FocusSchedule) {
        if let index = schedules.firstIndex(where: { $0.id == schedule.id }) {
            schedules[index].isEnabled.toggle()
            saveSchedules()
        }
    }
    
    // Проверка, активно ли какое-либо расписание сейчас
    func isAnyScheduleActive() -> Bool {
        return schedules.contains { $0.isActiveNow() }
    }
    
    // Получение списка активных сейчас расписаний
    func getActiveSchedules() -> [FocusSchedule] {
        return schedules.filter { $0.isActiveNow() }
    }
}
