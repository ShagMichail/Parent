//
//  AddFocusTimeView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 08.12.2025.
//

import SwiftUI

struct AddFocusTimeView: View {
    let mode: FocusTimeMode
    let scheduleToEdit: FocusSchedule?
    let onSave: (FocusSchedule) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var startTime: Date
    @State private var endTime: Date
    @State private var selectedDays: Set<FocusSchedule.Weekday>
    @State private var showingDaysSheet = false
    @State private var isEnabled = true
    
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    init(mode: FocusTimeMode,
         scheduleToEdit: FocusSchedule? = nil,
         onSave: @escaping (FocusSchedule) -> Void
    ) {
        self.mode = mode
        self.scheduleToEdit = scheduleToEdit
        self.onSave = onSave
        
        // Инициализируем состояние в зависимости от режима
        switch mode {
        case .add:
            _startTime = State(initialValue: Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: Date()) ?? Date())
            _endTime = State(initialValue: Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date()) ?? Date())
            _selectedDays = State(initialValue: [.monday, .tuesday, .wednesday, .thursday, .friday])
            _isEnabled = State(initialValue: true)
            
        case .edit(let schedule):
            _startTime = State(initialValue: schedule.startTime)
            _endTime = State(initialValue: schedule.endTime)
            _selectedDays = State(initialValue: Set(schedule.daysOfWeek))
            _isEnabled = State(initialValue: schedule.isEnabled)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Кастомный NavigationBar
            NavigationBar(
                model: NavigationBarModel(
                    chevronBackward: true,
                    subTitle: {
                        switch mode {
                        case .add: return "Добавить время фокусировки"
                        case .edit: return "Редактировать время фокусировки"
                        }
                    }(),
                    hasConfirm: true,
                    onBackTap: {
                        dismiss()
                    },
                    onNotificationTap: {},
                    onConfirmTap: {
                        saveSchedule()
                    }
                )
            )
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Секция времени
                    VStack(alignment: .leading) {
                        
                        VStack(spacing: 0) {
                            TimeRow(title: "Начало", time: $startTime)
                                .padding(.top, 20)
                                .padding(.bottom, 15)
                                .padding(.horizontal, 10)
                            
                            Divider()
                                .padding(.horizontal, 10)
                            
                            TimeRow(title: "Конец", time: $endTime)
                                .padding(.bottom, 20)
                                .padding(.top, 15)
                                .padding(.horizontal, 10)
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white)
                        )
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                    
                    // Секция повторения
                    VStack(alignment: .leading) {
                        // Кнопка выбора дней
                        Button(action: { showingDaysSheet = true }) {
                            HStack {
                                
                                    Text("Дни недели")
                                        .font(.system(size: 16, weight: .regular, design: .rounded))
                                        .foregroundColor(.blackText)
                                    Spacer()
                                HStack(spacing: 6) {
                                    Text(formatSelectedDays())
                                        .font(.system(size: 16, weight: .regular, design: .rounded))
                                        .foregroundColor(.strokeTextField)
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.strokeTextField)
                                }
                            }
                            .padding(.vertical, 20)
                            .padding(.horizontal, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.white)
                            )
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        }
                        
                        // Быстрые кнопки
                        HStack(spacing: 12) {
                            PresetButton(
                                title: "пн-пт",
                                isActive: isWeekdaysSelected,
                                action: { selectedDays = [.monday, .tuesday, .wednesday, .thursday, .friday] }
                            )
                            
                            PresetButton(
                                title: "сб-вс",
                                isActive: isWeekendSelected,
                                action: { selectedDays = [.saturday, .sunday] }
                            )
                            
                            PresetButton(
                                title: "Все",
                                isActive: isAllDaysSelected,
                                action: { selectedDays = Set(FocusSchedule.Weekday.allCases) }
                            )
                        }
                    }
                    
                    // Переключатель активности
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Активно")
                                .foregroundColor(.blackText)
                            
                            Spacer()
                            
                            Toggle("", isOn: $isEnabled)
                                .labelsHidden()
                                .toggleStyle(KnobColorToggleStyle(activeColor: .accent))
                        }
                        .padding(.vertical, 20)
                        .padding(.horizontal, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white)
                        )
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
            }
        }
        .background(Color.roleBackground.ignoresSafeArea())
        .navigationBarHidden(true)
        .sheet(isPresented: $showingDaysSheet) {
            DaysSelectionSheet(selectedDays: $selectedDays)
        }
        .alert("Ошибка времени", isPresented: $showingAlert) {
            Button("ОК", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    // Вычисляемые свойства для быстрых кнопок
    private var isWeekdaysSelected: Bool {
        let weekdays: Set<FocusSchedule.Weekday> = [.monday, .tuesday, .wednesday, .thursday, .friday]
        return weekdays == selectedDays
    }
    
    private var isWeekendSelected: Bool {
        let weekend: Set<FocusSchedule.Weekday> = [.saturday, .sunday]
        return weekend == selectedDays
    }
    
    private var isAllDaysSelected: Bool {
        Set(FocusSchedule.Weekday.allCases) == selectedDays
    }
    
    private func formatSelectedDays() -> String {
        if selectedDays.isEmpty { return "Не выбрано" }
        if isAllDaysSelected { return "Каждый день" }
        if isWeekdaysSelected { return "пн-пт" }
        if isWeekendSelected { return "сб-вс" }
        
        let sortedDays = selectedDays.sorted { $0.rawValue < $1.rawValue }
        return sortedDays.map { $0.shortName }.joined(separator: ", ")
    }
    
    private func saveSchedule() {
        // 1. ПРОВЕРКА ИНТЕРВАЛА
        let calendar = Calendar.current
        
        let startComp = calendar.dateComponents([.hour, .minute], from: startTime)
        let endComp = calendar.dateComponents([.hour, .minute], from: endTime)
        
        let startMinutes = (startComp.hour! * 60) + startComp.minute!
        let endMinutes = (endComp.hour! * 60) + endComp.minute!
        
        var diff = endMinutes - startMinutes
        
        // Обработка перехода через полночь (например, 23:50 -> 00:10)
        // 1430 (23:50) -> 10 (00:10). Разница -1420.
        // Добавляем 24 часа (1440 мин) -> получаем 20 минут.
        if diff < 0 {
            diff += 1440
        }
        
        // Сама проверка (15 минут = 15)
        if diff < 15 {
            alertMessage = "Минимальное время фокусировки — 15 минут."
            showingAlert = true
            return // 🛑 Прерываем сохранение
        }
        
        // 2. ПРОВЕРКА ДНЕЙ (Опционально, но полезно)
        if selectedDays.isEmpty {
            alertMessage = "Выберите хотя бы один день недели."
            showingAlert = true
            return
        }
        
        // 3. СОХРАНЕНИЕ (Если все ок)
        let schedule: FocusSchedule
        
        switch mode {
        case .add:
            schedule = FocusSchedule(
                startTime: startTime,
                endTime: endTime,
                daysOfWeek: Array(selectedDays),
                isEnabled: isEnabled
            )
            
        case .edit(let originalSchedule):
            // Для редактирования важно сохранить старый ID
            schedule = FocusSchedule(
                id: originalSchedule.id,
                startTime: startTime,
                endTime: endTime,
                daysOfWeek: Array(selectedDays),
                isEnabled: isEnabled
            )
        }
        
        onSave(schedule)
    }
}
