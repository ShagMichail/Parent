//
//  AddFocusTimeView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 08.12.2025.
//

import SwiftUI

enum FocusTimeMode {
    case add
    case edit(FocusSchedule)
}

struct AddFocusTimeView: View {
    let mode: FocusTimeMode
    let scheduleToEdit: FocusSchedule?
    let onSave: (FocusSchedule) -> Void
//    let onCancel: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var startTime: Date
    @State private var endTime: Date
    @State private var selectedDays: Set<FocusSchedule.Weekday>
    @State private var showingDaysSheet = false
    @State private var isEnabled = true
    
    init(mode: FocusTimeMode,
         scheduleToEdit: FocusSchedule? = nil,
         onSave: @escaping (FocusSchedule) -> Void
//         ,
//         onCancel: @escaping () -> Void
    ) {
        self.mode = mode
        self.scheduleToEdit = scheduleToEdit
        self.onSave = onSave
//        self.onCancel = onCancel
        
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
                    onBackTap: {
                        dismiss()
                    },
                    onNotificationTap: {}
                )
            )
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Секция времени
                    VStack(alignment: .leading, spacing: 12) {
                        Text("ВРЕМЯ")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 4)
                        
                        VStack(spacing: 0) {
                            TimeRow(title: "Начало", time: $startTime)
                                .padding(.vertical, 16)
                                .padding(.horizontal, 16)
                            
                            Divider()
                                .padding(.leading, 16)
                            
                            TimeRow(title: "Конец", time: $endTime)
                                .padding(.vertical, 16)
                                .padding(.horizontal, 16)
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white)
                        )
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                    
                    // Секция повторения
                    VStack(alignment: .leading, spacing: 12) {
                        Text("ПОВТОР")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 4)
                        
                        // Кнопка выбора дней
                        Button(action: { showingDaysSheet = true }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Дни недели")
                                        .foregroundColor(.primary)
                                    Text(formatSelectedDays())
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 16)
                            .padding(.horizontal, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
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
                        Text("СТАТУС")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 4)
                        
                        HStack {
                            Text("Активно")
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Toggle("", isOn: $isEnabled)
                                .labelsHidden()
                                .toggleStyle(SwitchToggleStyle(tint: .focus))
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white)
                        )
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
            }
            
            // Кнопка сохранения
            Button(action: saveSchedule) {
                Group {
                    switch mode {
                    case .add:
                        Text("Добавить")
                    case .edit:
                        Text("Сохранить изменения")
                    }
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(selectedDays.isEmpty ? Color.gray : Color.focus)
                )
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .disabled(selectedDays.isEmpty)
        }
        .background(Color.roleBackround.ignoresSafeArea())
        .navigationBarHidden(true)
        .sheet(isPresented: $showingDaysSheet) {
            DaysSelectionSheet(selectedDays: $selectedDays)
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
        dismiss()
    }
}

// Обновленная структура TimeRow с DatePicker
struct TimeRow: View {
    let title: String
    @Binding var time: Date
    @State private var showingTimePicker = false
    
    var body: some View {
        Button(action: {
            showingTimePicker = true
        }) {
            HStack {
                Text(title)
                    .foregroundColor(.primary)
                Spacer()
                Text(time, style: .time)
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.blue)
            }
        }
        .sheet(isPresented: $showingTimePicker) {
            VStack {
                DatePicker("", selection: $time, displayedComponents: .hourAndMinute)
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
                    .frame(maxWidth: .infinity)
                    .padding()
                
                Button("Готово") {
                    showingTimePicker = false
                }
                .padding()
            }
            .presentationDetents([.height(300)])
            .presentationDragIndicator(.visible)
        }
    }
}

// Обновленный DaysSelectionSheet
struct DaysSelectionSheet: View {
    @Binding var selectedDays: Set<FocusSchedule.Weekday>
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Кастомный NavigationBar для sheet
            HStack {
                Button(action: { dismiss() }) {
                    Text("Отмена")
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                Text("Выберите дни")
                    .font(.headline)
                
                Spacer()
                
                Button(action: { dismiss() }) {
                    Text("Готово")
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            
            List {
                ForEach(FocusSchedule.Weekday.allCases, id: \.self) { day in
                    Button(action: {
                        if selectedDays.contains(day) {
                            selectedDays.remove(day)
                        } else {
                            selectedDays.insert(day)
                        }
                    }) {
                        HStack {
                            Text(day.fullName)
                                .foregroundColor(.primary)
                            Spacer()
                            if selectedDays.contains(day) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
        }
    }
}

// Компонент PresetButton
struct PresetButton: View {
    let title: String
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(isActive ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                .foregroundColor(isActive ? .blue : .primary)
                .cornerRadius(8)
        }
    }
}
