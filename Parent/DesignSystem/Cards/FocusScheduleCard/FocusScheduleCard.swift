//
//  FocusScheduleCard.swift
//  Parent
//
//  Created by Михаил Шаговитов on 09.12.2025.
//

import SwiftUI

struct FocusScheduleCard: View {
    let model: FocusScheduleCardModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(model.schedule.timeString)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.blackText)
                
                Text(model.schedule.daysString)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.strokeTextField)
                    .textCase(.uppercase)
            }
            
            Spacer()
            
            Toggle("", isOn: Binding(
                get: { model.schedule.isEnabled },
                set: { _ in model.onToggle() }
            ))
                .labelsHidden()
                .toggleStyle(KnobColorToggleStyle(activeColor: .accent))
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
    }
}
