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
    let onDismiss: () -> Void
    
//    @Environment(\.dismiss) private var dismiss
    
    @State private var startTime: Date
    @State private var endTime: Date
    @State private var selectedDays: Set<FocusSchedule.Weekday>
    @State private var showingDaysSheet = false
    @State private var isEnabled = true
    
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    private let minimumInterval: TimeInterval = 15 * 60 // 15 минут в секундах
    
    init(mode: FocusTimeMode,
         scheduleToEdit: FocusSchedule? = nil,
         onSave: @escaping (FocusSchedule) -> Void,
         onDismiss: @escaping () -> Void
    ) {
        self.mode = mode
        self.scheduleToEdit = scheduleToEdit
        self.onSave = onSave
        self.onDismiss = onDismiss
        
        switch mode {
        case .add:
            _startTime = State(initialValue: .now)
            _endTime = State(initialValue: .now.addingTimeInterval(minimumInterval))
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
                        case .add: return String(localized: "Add focus time")
                        case .edit: return String(localized: "Edit focus time")
                        }
                    }(),
                    hasConfirm: true,
                    onBackTap: {
                        onDismiss()
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
                            TimeRow(title: String(localized: "Start"), time: $startTime)
                                .padding(.top, 20)
                                .padding(.bottom, 15)
                                .padding(.horizontal, 10)
                            
                            Divider()
                                .padding(.horizontal, 10)
                            
                            TimeRow(title: String(localized: "End"), time: $endTime)
                                .padding(.bottom, 20)
                                .padding(.top, 15)
                                .padding(.horizontal, 10)
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white)
                        )
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        .onChange(of: startTime) { _, newStartTime in
                            validateAndAdjustEndTime(basedOn: newStartTime)
                        }
                        .onChange(of: endTime) { _, newEndTime in
                            validateAndAdjustStartTime(basedOn: newEndTime)
                        }
                    }
                    
                    // Секция повторения
                    VStack(alignment: .leading) {
                        // Кнопка выбора дней
                        Button(action: { showingDaysSheet = true }) {
                            HStack {
                                
                                Text("Weekday")
                                    .font(.custom("Inter-Regular", size: 16))
                                    .foregroundColor(.blackText)
                                
                                    Spacer()
                                HStack(spacing: 6) {
                                    Text(formatSelectedDays())
                                        .font(.custom("Inter-Regular", size: 16))
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
                                title: String(localized: "mon-fri"),
                                isActive: isWeekdaysSelected,
                                action: { selectedDays = [.monday, .tuesday, .wednesday, .thursday, .friday] }
                            )
                            
                            PresetButton(
                                title: String(localized: "sat-sun"),
                                isActive: isWeekendSelected,
                                action: { selectedDays = [.saturday, .sunday] }
                            )
                            
                            PresetButton(
                                title: String(localized: "All"),
                                isActive: isAllDaysSelected,
                                action: { selectedDays = Set(FocusSchedule.Weekday.allCases) }
                            )
                        }
                    }
                    
                    // Переключатель активности
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Actively")
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
        .alert("Time error", isPresented: $showingAlert) {
            Button("Continue", role: .cancel) { }
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
        if selectedDays.isEmpty { return String(localized: "Not selected") }
        if isAllDaysSelected { return String(localized: "Every day") }
        if isWeekdaysSelected { return String(localized: "mon-fri") }
        if isWeekendSelected { return String(localized: "sat-sun") }
        
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
            alertMessage = String(localized: "The minimum time limit is 15 minutes.")
            showingAlert = true
            return // 🛑 Прерываем сохранение
        }
        
        // 2. ПРОВЕРКА ДНЕЙ
        if selectedDays.isEmpty {
            alertMessage = String(localized: "Choose at least one day of the week.")
            showingAlert = true
            return
        }
        
        // 3. СОХРАНЕНИЕ
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
    
    /// Проверяет и корректирует ВРЕМЯ КОНЦА, если оно стало некорректным
    private func validateAndAdjustEndTime(basedOn newStartTime: Date) {
        // Сравниваем время конца с новым временем начала + 15 минут
        if endTime <= newStartTime.addingTimeInterval(minimumInterval - 1) {
            // Если время конца раньше (или слишком близко),
            // устанавливаем его на 15 минут позже времени начала
            endTime = newStartTime.addingTimeInterval(minimumInterval)
            print("⏰ Время конца скорректировано!")
        }
    }
    
    /// Проверяет и корректирует ВРЕМЯ НАЧАЛА, если оно стало некорректным
    private func validateAndAdjustStartTime(basedOn newEndTime: Date) {
        // Сравниваем время начала с новым временем конца - 15 минут
        if startTime >= newEndTime.addingTimeInterval(-minimumInterval + 1) {
            // Если время начала позже (или слишком близко),
            // устанавливаем его на 15 минут раньше времени конца
            startTime = newEndTime.addingTimeInterval(-minimumInterval)
            print("⏰ Время начала скорректировано!")
        }
    }
}
