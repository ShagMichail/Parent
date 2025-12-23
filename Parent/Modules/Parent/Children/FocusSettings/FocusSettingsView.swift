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
    @Binding var showNavigationBar: Bool
    let childID: String
    
    @State private var selectedScheduleForActions: FocusSchedule? = nil
    
    @Namespace private var animationNamespace
    
    var body: some View {
        ZStack {
            mainContent
                .blur(radius: selectedScheduleForActions != nil ? 5 : 0) // Блюрим фон
            
            // --- СЛОЙ 2: Затемнение и модальное окно ---
            if let selectedSchedule = selectedScheduleForActions {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        // Закрываем при нажатии на фон
                        withAnimation(.spring()) {
                            selectedScheduleForActions = nil
                        }
                    }
                    .transition(.opacity)
                
                // Слой с активной карточкой и кнопками
                VStack(spacing: 16) {
                    FocusScheduleCard(
                        model: FocusScheduleCardModel(
                            schedule: selectedSchedule,
                            onToggle: {
                                // 1. Локальное переключение (для мгновенной реакции UI)
                                scheduleManager.toggleSchedule(selectedSchedule)
                                
                                // 2. ВАЖНО: Получаем уже обновленную версию расписания из менеджера
                                // (так как schedule в замыкании — это старая копия до переключения)
                                if let updatedSchedule = scheduleManager.schedules.first(where: { $0.id == selectedSchedule.id }) {
                                    
                                    // 3. Отправляем изменение в CloudKit
                                    Task {
                                        do {
                                            // Используем childID, который передан в FocusSettingsView
                                            try await CloudKitManager.shared.saveFocusSchedule(updatedSchedule, for: childID)
                                            print("☁️ Статус тогла успешно отправлен в CloudKit")
                                        } catch {
                                            print("🚨 Ошибка сохранения тогла: \(error)")
                                        }
                                    }
                                }
                            }
                        )
                    )
                    .matchedGeometryEffect(id: selectedSchedule.id, in: animationNamespace)
                    .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
                    
                    // Кнопки действий
                    HStack(spacing: 12) {
                        // Кнопка Редактировать
                        Button {
                            withAnimation {
                                selectedScheduleForActions = nil
                                scheduleToEdit = selectedSchedule
                            }
                        } label: {
                            HStack {
                                Image(systemName: "pencil")
                                Text("Изменить")
                            }
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(16)
                        }
                        
                        // Кнопка Удалить
                        Button {
                            withAnimation {
                                scheduleManager.deleteSchedule(selectedSchedule)
                                Task {
                                    try? await CloudKitManager.shared.deleteFocusSchedule(selectedSchedule)
                                }
                                selectedScheduleForActions = nil
                            }
                        } label: {
                            HStack {
                                Image(systemName: "trash")
                                Text("Удалить")
                            }
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(16)
                        }
                    }
                    .padding(.horizontal, 20)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .padding(.horizontal, 20)
                .zIndex(2)
            }
        }
        .background(Color.roleBackground.ignoresSafeArea())
        .navigationBarHidden(true)
        
        // --- Навигационные ссылки (скрытые) ---
        .background(
            NavigationLink(
                destination: AddFocusTimeView(
                    mode: .add,
                    scheduleToEdit: nil,
                    onSave: { newSchedule in
                        scheduleManager.addSchedule(newSchedule)
                        // 2. В CloudKit
                        Task {
                            try? await CloudKitManager.shared.saveFocusSchedule(newSchedule, for: childID)
                        }
                        navigateToAddSchedule = false
                    }
                ),
                isActive: $navigateToAddSchedule
            ) { EmptyView() }.hidden()
        )
        .background(
            NavigationLink(
                destination: Group {
                    if let schedule = scheduleToEdit {
                        AddFocusTimeView(
                            mode: .edit(schedule),
                            scheduleToEdit: schedule,
                            onSave: { updated in
                                scheduleManager.updateSchedule(updated)
                                scheduleToEdit = nil
                            }
                        )
                    }
                },
                isActive: Binding(
                    get: { scheduleToEdit != nil },
                    set: { if !$0 { scheduleToEdit = nil } }
                )
            ) { EmptyView() }.hidden()
        )
    }
    
    // Вынес основной контент в переменную для чистоты
    var mainContent: some View {
        VStack(spacing: 0) {
            NavigationBar(
                model: NavigationBarModel(
                    chevronBackward: true,
                    subTitle: "Фокусировка",
                    onBackTap: {
                        dismiss()
                        showNavigationBar.toggle()
                    },
                    onNotificationTap: {},
                    onConfirmTap: {}
                )
            )
            
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    
                    Text("Когда функция включена, пользователь сможет проверять только время, звонить родителям и использовать экстренные сигналы")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(.strokeTextField)
                    
                    VStack(spacing: 10) {
                        ForEach(scheduleManager.schedules) { schedule in
                            if selectedScheduleForActions?.id == schedule.id {
                                FocusScheduleCard(
                                    model: FocusScheduleCardModel(
                                        schedule: schedule,
                                        onToggle: {}
                                    )
                                )
                                .hidden()
                                .frame(height: 70)
                            } else {
                                FocusScheduleCard(
                                    model: FocusScheduleCardModel(
                                        schedule: schedule,
                                        onToggle: {
                                            // 1. Локальное переключение (для мгновенной реакции UI)
                                            scheduleManager.toggleSchedule(schedule)
                                            
                                            // 2. ВАЖНО: Получаем уже обновленную версию расписания из менеджера
                                            // (так как schedule в замыкании — это старая копия до переключения)
                                            if let updatedSchedule = scheduleManager.schedules.first(where: { $0.id == schedule.id }) {
                                                
                                                // 3. Отправляем изменение в CloudKit
                                                Task {
                                                    do {
                                                        // Используем childID, который передан в FocusSettingsView
                                                        try await CloudKitManager.shared.saveFocusSchedule(updatedSchedule, for: childID)
                                                        print("☁️ Статус тогла успешно отправлен в CloudKit")
                                                    } catch {
                                                        print("🚨 Ошибка сохранения тогла: \(error)")
                                                    }
                                                }
                                            }
                                        }
                                    )
                                )
                                .matchedGeometryEffect(id: schedule.id, in: animationNamespace)
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                        selectedScheduleForActions = schedule
                                    }
                                }
                            }
                        }
                        
                        Button(action: {
                            navigateToAddSchedule = true
                        }) {
                            HStack(spacing: 6) {
                                Image("focus-command")
                                    .resizable()
                                    .frame(width: 16, height: 16)
                                Text("Добавить время")
                                    .font(.system(size: 16, weight: .regular))
                            }
                            .foregroundColor(.focus)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 20)
                            .padding(.horizontal, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 20).fill(.white)
                            )
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}
