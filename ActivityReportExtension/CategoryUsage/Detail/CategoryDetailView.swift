//
//  CategoryDetailView.swift
//  Parent
//
//  Created by Michail Shagovitov on 23.12.2025.
//

import SwiftUI
import Charts
import FamilyControls

struct CategoryDetailView: View {
    let detail: CategoryUsageDetail
    let chartType: ChartDetailType
    
    private var dailyChartData: [DailyActivityModel] {
        var completeWeekData: [DailyActivityModel] = []
        let calendar = Calendar.current
        let today = Date()
        
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                let dayStart = calendar.startOfDay(for: date)
                let durationForDay = detail.dailyUsage[dayStart] ?? 0
                completeWeekData.append(DailyActivityModel(date: dayStart, duration: durationForDay))
            }
        }
        return completeWeekData.sorted { $0.date < $1.date }
    }
    
    private var hourlyChartData: [HourlyActivityModel] {
        detail.hourlyUsage.enumerated().map { (hour, duration) in
            HourlyActivityModel(hour: hour, duration: duration)
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Количество уведомлений")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(.blackText)
                    
                    HStack {
                        Text("\(detail.totalNotifications)")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.redStat)
                        Text(chartType == .daily ? "за неделю" : "за сегодня")
                            .font(.system(size: 18, weight: .regular, design: .rounded))
                            .foregroundColor(.timestamps)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        headerView
                        
                        if chartType == .daily {
                            weekChartView
                        } else {
                            dayChartView
                        }
                    }
                    .padding(.vertical, 20)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
                }
                
                // --- ✅ БЛОК 2: Статистика по УВЕДОМЛЕНИЯМ ---
                VStack(alignment: .leading, spacing: 10) {
                    Text("Приложения")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(.blackText)
                    
                    VStack(alignment: .leading) {
                        // Список приложений с количеством уведомлений
                        if detail.totalNotifications == 0 {
                            HStack {
                                Text("Нет данных")
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.leading)
                                    .padding(.vertical, 20)
                                    .padding(.horizontal, 10)
                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                        } else {
                            ForEach(detail.applications) { appDetail in
                                // Показываем только если были уведомления
                                if appDetail.totalNotifications > 0 {
                                    HStack {
                                        Label(appDetail.token).labelStyle(.iconOnly)
                                            .frame(width: 24, height: 24)
                                        Text(appDetail.application.localizedDisplayName ?? "Приложение")
                                        Spacer()
                                        Text("\(appDetail.totalNotifications)")
                                            .fontWeight(.semibold)
                                    }
                                    .padding(.vertical, 20)
                                    .padding(.horizontal, 10)
                                }
                            }
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(20)
                }
            }
            .padding(.horizontal, 20)
        }
        .scrollIndicators(.hidden)
        .background(.backgroundApps)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: 8) {
                    Label(detail.category.token!)
                        .labelStyle(.iconOnly)
                        .frame(width: 24, height: 24)
                    
                    Label(detail.category.token!)
                        .labelStyle(.titleOnly)
                        .font(.system(size: 16))
                        .foregroundColor(.blackText)
                }
            }
        }

    }
    
    private var headerView: some View {
        HStack {
            let durationToShow = detail.totalDuration

            Text(formatTotalDuration(durationToShow))
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(.blackText)
            Spacer()
            Text(chartType == .daily ? "Последние 7 дней" : "Сегодня, \(getDateString())")
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(.data)
        }
        .padding(.horizontal, 10)
    }
    
    private var dayChartView: some View {
        Chart(hourlyChartData) { item in
            BarMark(
                x: .value("Час", item.hour),
                y: .value("Секунды", item.duration)
            )
            .foregroundStyle(.accent)
            .cornerRadius(3)
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
    }
    
    private var weekChartView: some View {
        Chart(dailyChartData) { dataPoint in
            BarMark(
                x: .value("День", dataPoint.dateString),
                y: .value("Секунды", dataPoint.duration)
            )
            .foregroundStyle(.accent)
            .cornerRadius(3)
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
    }
}
