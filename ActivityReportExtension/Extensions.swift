//
//  Extensions.swift
//  Parent
//
//  Created by Michail Shagovitov on 23.12.2025.
//

import Foundation

func formatTotalDuration(_ duration: TimeInterval) -> String {
    let formatter = DateComponentsFormatter()
    formatter.unitsStyle = .abbreviated
    formatter.zeroFormattingBehavior = .dropAll
    if duration < 60 { return "\(Int(duration)) сек" }
    formatter.allowedUnits = [.hour, .minute]
    var calendar = Calendar.current
    calendar.locale = Locale(identifier: "ru_RU")
    formatter.calendar = calendar
    return formatter.string(from: duration) ?? "0 мин"
}

func getDateString() -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ru_RU")
    formatter.dateFormat = "d MMMM"
    return formatter.string(from: Date())
}
