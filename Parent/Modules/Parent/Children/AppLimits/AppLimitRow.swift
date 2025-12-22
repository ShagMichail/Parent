//
//  AppLimitRow.swift
//  Parent
//
//  Created by Michail Shagovitov on 22.12.2025.
//

import SwiftUI

struct AppLimitRow: View {
    // Binding к нашему лимиту
    @Binding var limit: AppLimit
    
    // State для показа/скрытия пикера
    @State private var showTimePicker = false

    /// "Прокси" Binding, который конвертирует TimeInterval в Date и обратно
    private var timeBinding: Binding<Date> {
        Binding<Date>(
            // GET: Превращаем секунды в Date
            get: {
                // Создаем "нулевую" дату (начало сегодняшнего дня)
                let calendar = Calendar.current
                let today = calendar.startOfDay(for: Date())
                // Прибавляем к ней наш лимит в секундах
                return today.addingTimeInterval(limit.time)
            },
            // SET: Превращаем Date из пикера обратно в секунды
            set: { newDate in
                let calendar = Calendar.current
                let today = calendar.startOfDay(for: Date())
                // Вычисляем разницу в секундах между выбранным временем и началом дня
                let components = calendar.dateComponents([.hour, .minute], from: newDate)
                let newTimeInSeconds = TimeInterval((components.hour ?? 0) * 3600 + (components.minute ?? 0) * 60)
                limit.time = newTimeInSeconds
            }
        )
    }
    
    var body: some View {
        HStack {
            Label(limit.token)
            
            Spacer()
            
            Button(action: {
                showTimePicker = true
            }) {
                Text(formatDuration(limit.time))
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.accent)
                    .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 10)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.white)
            }
        )
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .contentShape(Rectangle())
        .sheet(isPresented: $showTimePicker) {
            VStack {
                Text("Установить дневной лимит")
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(.strokeTextField)
                    .padding(.top, 60)

                DatePicker(
                    "",
                    selection: timeBinding,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                
                Button("Готово") {
                    showTimePicker = false
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
            .presentationDetents([.height(320)])
            .presentationDragIndicator(.visible)
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated // "1ч 30м"
        formatter.allowedUnits = [.hour, .minute]
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "ru_RU")
        formatter.calendar = calendar
        if duration == 0 {
            return "Без лимита"
        }
        
        return formatter.string(from: duration) ?? ""
    }
}
