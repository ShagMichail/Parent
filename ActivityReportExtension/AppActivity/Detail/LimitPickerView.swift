//
//  LimitPickerView.swift
//  Parent
//
//  Created by Michail Shagovitov on 17.12.2025.
//

import SwiftUI

struct LimitPickerView: View {
    @Environment(\.dismiss) var dismiss
    @State private var timeLimit: TimeInterval = 3600 // 1 час
    let onSave: (TimeInterval) -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Установить дневной лимит")) {
                    DatePicker("Время", selection: Binding(
                        get: { Date(timeIntervalSinceReferenceDate: timeLimit) },
                        set: { timeLimit = $0.timeIntervalSinceReferenceDate }
                    ), displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                }
                
                // Кнопка для снятия лимита
                Section {
                    Button("Снять лимит", role: .destructive) {
                        onSave(0) // Отправляем 0, чтобы удалить лимит
                        dismiss()
                    }
                }
            }
            .navigationTitle("Лимит времени")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        onSave(timeLimit)
                        dismiss()
                    }
                }
            }
        }
    }
}
