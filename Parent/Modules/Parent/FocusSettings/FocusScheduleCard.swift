//
//  FocusScheduleCard.swift
//  Parent
//
//  Created by Михаил Шаговитов on 08.12.2025.
//

import SwiftUI

//struct FocusScheduleCard: View {
//    @Binding var schedule: FocusSchedule
//    
//    var body: some View {
//        HStack {
//            VStack(alignment: .leading, spacing: 6) {
//                Text("\(schedule.startTime)–\(schedule.endTime)")
//                    .font(.system(size: 16, weight: .regular))
//                    .foregroundColor(.blackText)
//                
//                // Дни недели
//                Text(schedule.days)
//                    .font(.system(size: 16, weight: .regular))
//                    .foregroundColor(.strokeTextField)
//                    .textCase(.uppercase)
//            }
//            
//            Spacer()
//            
//            // Тогл (Переключатель)
//            Toggle("", isOn: $schedule.isEnabled)
//                .labelsHidden()
//                .toggleStyle(KnobColorToggleStyle(activeColor: .accent))
//        }
//        .padding(.vertical, 20)
//        .padding(.horizontal, 10)
//        .background(
//            ZStack {
//                RoundedRectangle(cornerRadius: 20)
//                    .fill(.white)
//            }
//        )
//        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
//    }
//}
//
//import SwiftUI
//
//struct KnobColorToggleStyle: ToggleStyle {
//    var activeColor: Color = .purple // Цвет точки, когда включено
//    var inactiveKnobColor: Color = .white // Цвет точки, когда выключено
//    var trackColor: Color = Color(uiColor: .systemGray5) // Цвет фона (всегда серый)
//    
//    func makeBody(configuration: Configuration) -> some View {
//        HStack {
//            // Текст метки (если есть)
//            configuration.label
//            
//            // Сам переключатель
//            ZStack(alignment: configuration.isOn ? .trailing : .leading) {
//                // 1. Фон (Track) - всегда серый
//                Capsule()
//                    .fill(trackColor)
//                    .frame(width: 51, height: 31)
//                
//                // 2. Кружок (Knob)
//                Circle()
//                    .fill(configuration.isOn ? activeColor : inactiveKnobColor)
//                    .frame(width: 27, height: 27)
//                    .padding(2) // Отступ от края
//                    .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1) // Тень для объема
//            }
//            .onTapGesture {
//                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
//                    configuration.isOn.toggle()
//                }
//            }
//        }
//    }
//}

struct FocusScheduleCard: View {
    let schedule: FocusSchedule
    let onToggle: () -> Void
    let onEdit: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Переключатель
            Toggle("", isOn: Binding(
                get: { schedule.isEnabled },
                set: { _ in onToggle() }
            ))
            .labelsHidden()
            .toggleStyle(SwitchToggleStyle(tint: .focus))
            .scaleEffect(0.8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(schedule.timeString)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(schedule.daysString)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Иконка для редактирования
            Button(action: onEdit) {
                Image(systemName: "pencil.circle.fill")
                    .foregroundColor(.focus.opacity(0.7))
                    .imageScale(.large)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .contextMenu {
            Button(role: .destructive) {
                // Удаление расписания
                FocusScheduleManager.shared.deleteSchedule(schedule)
            } label: {
                Label("Удалить", systemImage: "trash")
            }
        }
    }
}
