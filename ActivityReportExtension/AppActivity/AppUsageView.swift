//
//  CombinedActivityView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 24.11.2025.
//

import SwiftUI
import Charts

//struct AppUsageView: View {
//    let viewModel: ActivityReportViewModel
//    
//    var body: some View {
//        ScrollView {
//            VStack {
//                
//                // --- Блок "Экранное время" ---
//                VStack(alignment: .leading, spacing: 10) {
//                    Text("Экранное время")
//                        .font(.system(size: 20, weight: .semibold, design: .rounded))
//                        .foregroundColor(.blackText)
//                    
//                    VStack(alignment: .leading, spacing: 12) {
//                        HStack {
//                            // Если неделя - показываем сумму dailyData, если день - totalDuration
//                            let durationToShow = viewModel.isWeekView ? viewModel.dailyData.reduce(0) { $0 + $1.duration } : viewModel.totalDuration
//                            
//                            Text(formatTotalDuration(durationToShow))
//                                .font(.system(size: 18, weight: .semibold, design: .rounded))
//                                .foregroundColor(.blackText)
//                            Spacer()
//                            Text(viewModel.isWeekView ? "Последние 7 дней" : "Сегодня, \(getDateString())")
//                                .font(.system(size: 14, weight: .regular, design: .rounded))
//                                .foregroundColor(.gray)
//                        }
//                        .padding(.horizontal, 10)
//                        
//                        // --- ВЫБОР ГРАФИКА ---
//                        if viewModel.isWeekView {
//                            // === НЕДЕЛЯ ===
//                            Chart(viewModel.dailyData) { item in
//                                BarMark(x: .value("День", item.weekday), y: .value("Секунды", item.duration))
//                                    .foregroundStyle(Color.accentColor).cornerRadius(3)
//                            }
//                            .id("WeekChart")
//                            .chartYScale(domain: 0...86400) // 24 часа
//                            .chartYAxis {
//                                AxisMarks(position: .trailing, values: [0, 21600, 43200, 64800, 86400]) { value in
//                                    AxisValueLabel {
//                                        if let s = value.as(Int.self) { Text("\(s / 3600)").font(.caption2).foregroundColor(.gray) }
//                                    }
//                                }
//                            }
//                            .frame(height: 150)
//                        } else {
//                            // === ДЕНЬ ===
//                            Chart(viewModel.hourlyData) { item in
//                                BarMark(
//                                    x: .value("Час", item.hour),
//                                    y: .value("Секунды", min(item.duration, 3600)) // ПЕРЕДАЕМ СЕКУНДЫ
//                                )
//                                .foregroundStyle(Color.accentColor)
//                                .cornerRadius(3)
//                            }
//                            .id("DayChart") 
//                            .chartXScale(domain: 0...24)
//                            // !!! ВАЖНО: Фиксируем масштаб 0-3600, чтобы полоски не были огромными !!!
//                            .chartYScale(domain: 0.0 ... 3600.0)
//                            .chartXAxis {
//                                AxisMarks(values: [0, 6, 12, 18, 24]) { value in
//                                    AxisValueLabel { if let v = value.as(Int.self) { Text("\(v):00").font(.caption2).foregroundColor(.gray) } }
//                                }
//                            }
//                            .chartYAxis {
//                                AxisMarks(position: .trailing, values: [0, 1800, 3600]) { value in
//                                    AxisGridLine()
//                                    AxisValueLabel {
//                                        if let s = value.as(Int.self) {
//                                            // Делим на 60 для отображения "мин"
//                                            Text("\(s / 60)").font(.caption2).foregroundColor(.gray).padding(.trailing, 10)
//                                        }
//                                    }
//                                }
//                            }
//                            .frame(height: 120)
//                        }
//                        
//                        // Сравнение (показываем только для дня)
//                        if !viewModel.isWeekView {
//                            getComparisonText()
//                                .font(.system(size: 14, weight: .medium, design: .rounded))
//                                .padding(.horizontal, 10)
//                        }
//                    }
//                    .padding(.vertical, 20)
//                    .background(Color.white)
//                    .cornerRadius(20)
//                    .shadow(radius: 5)
//                }
//                
//                // --- СПИСОК ПРИЛОЖЕНИЙ ---
//                // (Этот код у тебя уже работает правильно, оставляй как есть)
//                VStack(alignment: .leading, spacing: 10) {
//                    // ... твой код списка приложений ...
//                    // чтобы не дублировать длинный текст, используй свой текущий блок списка
//                    Text("Используемые приложения")
//                        .font(.system(size: 20, weight: .semibold, design: .rounded))
//                        .foregroundColor(.blackText)
//                    
//                    VStack(spacing: 0) {
//                        ForEach(viewModel.apps.prefix(10)) { app in
//                            HStack {
//                                Label(app.token).labelStyle(.iconOnly).scaleEffect(1.2)
//                                Label(app.token).labelStyle(.titleOnly)
//                                    .font(.system(size: 16)).foregroundColor(.blackText).lineLimit(1)
//                                Spacer()
//                                Text(formatTotalDuration(app.duration))
//                                    .font(.system(size: 16)).foregroundColor(.timestamps)
//                            }
//                            .padding(.vertical, 16).padding(.horizontal, 10)
//                            if app.id != viewModel.apps.prefix(10).last?.id { Divider().padding(.leading, 50) }
//                        }
//                        if viewModel.apps.isEmpty { Text("Нет данных").padding() }
//                    }
//                    .background(Color.white).cornerRadius(20).shadow(radius: 1)
//                }
//            }
//            .padding(.horizontal, 20)
//            .padding(.bottom, 20)
//        }
//        .background(Color.backgroundApps)
//    }
//    
//    // Хелперы
//    @ViewBuilder
//    private func getComparisonText() -> some View {
//        let today = viewModel.totalDuration
//        let yesterday = viewModel.yesterdayTotalDuration
//        
//        if yesterday == 0 {
//            Text("Нет данных за вчерашний день")
//                .foregroundColor(.timestamps)
//        } else {
//            let difference = today - yesterday
//            let percentage = yesterday > 0 ? (difference / yesterday) * 100 : 0
//            let percentInt = Int(abs(percentage))
//            
//            if difference > 0 {
//                Text("+ \(percentInt)% в сравнении со вчерашним днём")
//                    .foregroundColor(.redStat)
//            } else if difference < 0 {
//                Text("- \(percentInt)% в сравнении со вчерашним днём")
//                    .foregroundColor(.greenStat)
//            } else {
//                Text("Столько же, сколько вчера")
//                    .foregroundColor(.timestamps)
//            }
//        }
//    }
//    
//    private func getDateString() -> String {
//        let formatter = DateFormatter()
//        formatter.locale = Locale(identifier: "ru_RU")
//        formatter.dateFormat = "d MMMM"
//        return formatter.string(from: Date())
//    }
//    
//    private func formatTotalDuration(_ duration: TimeInterval) -> String {
//        let formatter = DateComponentsFormatter()
//        formatter.unitsStyle = .abbreviated
//        formatter.zeroFormattingBehavior = .dropAll
//        if duration < 60 { return "\(Int(duration)) сек" }
//        formatter.allowedUnits = [.hour, .minute]
//        var calendar = Calendar.current
//        calendar.locale = Locale(identifier: "ru_RU")
//        formatter.calendar = calendar
//        return formatter.string(from: duration) ?? "0 мин"
//    }
//}


import SwiftUI
import Charts

import SwiftUI
import Charts

struct AppUsageView: View {
    let viewModel: ActivityReportViewModel
    
    var body: some View {
        ScrollView {
            VStack {
                // --- Блок "Экранное время" ---
                VStack(alignment: .leading, spacing: 10) {
                    Text("Экранное время")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(.blackText)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        
                        // 1. Заголовок
                        headerView
                        
                        // 2. Графики
                        if viewModel.isWeekView {
                            weekChartView
                        } else {
                            dayChartView
                        }
                        
                        // 3. Сравнение (только для дня)
                        if !viewModel.isWeekView {
                            comparisonView
                        }
                    }
                    .padding(.vertical, 20)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
                }
                .padding(.bottom, 16)
                
                // --- Список приложений ---
                appsListView
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(.backgroundApps)
    }
    
    // MARK: - Subviews
    
    // --- Заголовок ---
    private var headerView: some View {
        HStack {
            let durationToShow = viewModel.isWeekView ? viewModel.dailyData.reduce(0) { $0 + $1.duration } : viewModel.totalDuration
            
            Text(formatTotalDuration(durationToShow))
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(.blackText)
            Spacer()
            Text(viewModel.isWeekView ? "Последние 7 дней" : "Сегодня, \(getDateString())")
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(.data)
        }
        .padding(.horizontal, 10)
    }
    
    // --- ГРАФИК НЕДЕЛИ (0 - 24 часа) ---
    private var weekChartView: some View {
        Chart {
            ForEach(viewModel.dailyData) { item in
                BarMark(
                    x: .value("День", item.dateString),
                    y: .value("Секунды", item.duration)
                )
                .foregroundStyle(.accent)
                .cornerRadius(3)
            }

            RuleMark(y: .value("Max", 86400))
                .foregroundStyle(.clear)
        }
        .chartYScale(domain: 0...86400)
        .chartYAxis {
            AxisMarks(position: .trailing, values: [0, 21600, 43200, 64800, 86400]) { value in
                AxisGridLine()
                AxisValueLabel {
                    if let s = value.as(Int.self) {
                        Text("\(s / 3600)")
                            .font(.system(size: 12, weight: .regular, design: .rounded))
                            .foregroundColor(.timestamps)
                            .padding(.trailing, 10)
                    }
                }
            }
        }
        .frame(height: 150)
        .id("WeekChart")
    }
    
    // --- ГРАФИК ДНЯ (0 - 3600 сек) ---
    private var dayChartView: some View {
        Chart {
            ForEach(viewModel.hourlyData) { item in
                BarMark(
                    x: .value("Час", item.hour),
                    y: .value("Секунды", item.duration)
                )
                .foregroundStyle(.accent)
                .cornerRadius(3)
            }
            
            RuleMark(y: .value("Max", 3600))
                .foregroundStyle(.clear)
        }
        .chartXScale(domain: 0...24)
        .chartYScale(domain: 0...3600)
        .chartXAxis {
            AxisMarks(values: [0, 6, 12, 18, 24]) { value in
                AxisValueLabel {
                    if let v = value.as(Int.self) {
                        Text("\(v):00")
                            .font(.system(size: 12, weight: .regular, design: .rounded))
                            .foregroundColor(.timestamps)
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .trailing, values: [0, 1800, 3600]) { value in
                AxisGridLine()
                AxisValueLabel {
                    if let s = value.as(Int.self) {
                        Text("\(s / 60)")
                            .font(.system(size: 12, weight: .regular, design: .rounded))
                            .foregroundColor(.timestamps)
                            .padding(.trailing, 10)
                    }
                }
            }
        }
        .frame(height: 120)
        .id("DayChart")
    }
    
    // --- Сравнение ---
    @ViewBuilder
    private var comparisonView: some View {
        getComparisonText()
            .font(.system(size: 14, weight: .medium, design: .rounded))
            .padding(.horizontal, 10)
    }
    
    // --- Список приложений ---
    private var appsListView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Используемые приложения")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundColor(.blackText)
            
            VStack(spacing: 0) {
                ForEach(viewModel.apps.prefix(10)) { app in
                    HStack {
                        Label(app.token).labelStyle(.iconOnly)
                            .scaleEffect(1.2)
                        Label(app.token).labelStyle(.titleOnly)
                            .font(.system(size: 16))
                            .foregroundColor(.blackText)
                            .lineLimit(1)
                        Spacer()
                        Text(formatTotalDuration(app.duration))
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(.timestamps)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 20)
                    .padding(.horizontal, 10)
                    if app.id != viewModel.apps.prefix(10).last?.id {
                        Divider()
                            .padding(.horizontal, 10)
                    }
                }
                if viewModel.apps.isEmpty {
                    Text("Нет данных")
                        .padding()
                        .foregroundColor(.gray)
                }
            }
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
        }
    }
    
    // MARK: - Helpers
    
    @ViewBuilder
    private func getComparisonText() -> some View {
        let today = viewModel.totalDuration
        let yesterday = viewModel.yesterdayTotalDuration
        
        if yesterday == 0 {
            Text("Нет данных за вчера").foregroundColor(.gray)
        } else {
            let diff = today - yesterday
            let percent = Int(abs((diff / yesterday) * 100))
            if diff > 0 { Text("+ \(percent)% в сравнении со вчера").foregroundColor(.red) }
            else if diff < 0 { Text("- \(percent)% в сравнении со вчера").foregroundColor(.green) }
            else { Text("Столько же, сколько вчера").foregroundColor(.gray) }
        }
    }
    
    private func getDateString() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM"
        return formatter.string(from: Date())
    }
    
    private func formatTotalDuration(_ duration: TimeInterval) -> String {
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
}
