//
//  FocusScheduleCardModel.swift
//  Parent
//
//  Created by Михаил Шаговитов on 09.12.2025.
//

import Foundation

struct FocusScheduleCardModel {
    let schedule: FocusSchedule
    let onToggle: () -> Void
    init(schedule: FocusSchedule, onToggle: @escaping () -> Void) {
        self.schedule = schedule
        self.onToggle = onToggle
    }
}
