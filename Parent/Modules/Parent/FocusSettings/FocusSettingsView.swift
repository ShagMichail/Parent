//
//  FocusSettingsView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 08.12.2025.
//

import SwiftUI

struct FocusSettingsView: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var scheduleManager = FocusScheduleManager.shared
    @State private var navigateToAddSchedule = false
    @State private var scheduleToEdit: FocusSchedule?
    
    var body: some View {
        VStack(spacing: 0) {
            NavigationBar(
                model: NavigationBarModel(
                    chevronBackward: true,
                    subTitle: "Фокусировка",
                    onBackTap: {
                        dismiss()
                    },
                    onNotificationTap: {}
                )
            )
            
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    
                    // --- Текст описания ---
                    Text("Когда функция включена, пользователь сможет проверять только время, звонить родителям и использовать экстренные сигналы")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(.strokeTextField)
                    
                    // --- Список карточек ---
                    VStack(spacing: 10) {
                        ForEach(scheduleManager.schedules) { schedule in
                            FocusScheduleCard(schedule: schedule) {
                                scheduleManager.toggleSchedule(schedule)
                            } onEdit: {
                                // Редактирование расписания
                                editSchedule(schedule)
                            }
                        }
                        // --- Кнопка "Добавить время" ---
                        Button(action: {
                            // Логика добавления нового времени
                            navigateToAddSchedule = true
                        }) {
                            HStack(spacing: 6) {
                                Image("focus-command") // Или другая иконка часов
                                    .resizable()
                                    .frame(width: 16, height: 16)
                                
                                Text("Добавить время")
                                    .font(.system(size: 16, weight: .regular))
                            }
                            .foregroundColor(.focus) // Цвет текста и иконки
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 20)
                            .padding(.horizontal, 10)
                            .background(
                                ZStack {
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(.white)
                                }
                            )
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            .background(
                // Навигация на экран добавления
                NavigationLink(
                    destination: AddFocusTimeView(
                        mode: .add,
                        scheduleToEdit: nil,
                        onSave: { newSchedule in
                            scheduleManager.addSchedule(newSchedule)
                            navigateToAddSchedule = false
                        }
//                        ,
//                        onCancel: {
//                            navigateToAddSchedule = false
//                        }
                    ),
                    isActive: $navigateToAddSchedule
                ) {
                    EmptyView()
                }
                    .hidden()
            )
            .background(
                // Навигация на экран редактирования
                NavigationLink(
                    destination: Group {
                        if let schedule = scheduleToEdit {
                            AddFocusTimeView(
                                mode: .edit(schedule),
                                scheduleToEdit: schedule,
                                onSave: { updatedSchedule in
                                    scheduleManager.updateSchedule(updatedSchedule)
                                    scheduleToEdit = nil
                                }
//                                ,
//                                onCancel: {
//                                    scheduleToEdit = nil
//                                }
                            )
                        }
                    },
                    isActive: Binding(
                        get: { scheduleToEdit != nil },
                        set: { if !$0 { scheduleToEdit = nil } }
                    )
                ) {
                    EmptyView()
                }
                    .hidden()
            )
        }
        .background(Color.roleBackround.ignoresSafeArea())
        .navigationBarHidden(true)
    }
    
    private func editSchedule(_ schedule: FocusSchedule) {
        // Можно открыть модальное окно для редактирования
        // Пока просто добавим возможность удалить по долгому нажатию
    }
}
