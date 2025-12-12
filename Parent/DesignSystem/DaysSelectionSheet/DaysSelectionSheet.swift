//
//  DaysSelectionSheet.swift
//  Parent
//
//  Created by Michail Shagovitov on 10.12.2025.
//

import SwiftUI

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
