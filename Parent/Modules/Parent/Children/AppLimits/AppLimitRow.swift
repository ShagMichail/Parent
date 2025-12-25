//
//  AppLimitRow.swift
//  Parent
//
//  Created by Michail Shagovitov on 22.12.2025.
//

import SwiftUI

struct AppLimitRow: View {
    @Binding var limit: AppLimit
    
    @State private var showTimePicker = false

    private var timeBinding: Binding<Date> {
        Binding<Date>(
            get: {
                let calendar = Calendar.current
                let today = calendar.startOfDay(for: Date())
                return today.addingTimeInterval(limit.time)
            },
            set: { newDate in
                let calendar = Calendar.current
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
                    .font(.custom("Inter-Regular", size: 16))
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
                Text("Set a daily limit")
                    .font(.custom("Inter-Regular", size: 16))
                    .foregroundColor(.strokeTextField)
                    .padding(.top, 60)

                DatePicker(
                    "",
                    selection: timeBinding,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                
                Button("Done") {
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
        // НАДО предусмотреть локализацию от страны
        calendar.locale = Locale(identifier: "ru_RU")
        formatter.calendar = calendar
        if duration == 0 {
            return String(localized: "No limit")
        }
        
        return formatter.string(from: duration) ?? ""
    }
}
