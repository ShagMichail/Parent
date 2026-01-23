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
                    Text("Number of notifications")
                        .font(.custom("Inter-SemiBold", size: 20))
                        .foregroundColor(.blackText)
                    
                    HStack {
                        Text("\(detail.totalNotifications)")
                            .font(.custom("Inter-SemiBold", size: 18))
                            .foregroundColor(.redStat)
                        Text(chartType == .daily ? "in a week" : "for today")
                            .font(.custom("Inter-Regular", size: 18))
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
                
                // --- 2: Статистика по УВЕДОМЛЕНИЯМ ---
                VStack(alignment: .leading, spacing: 10) {
                    Text("Applications")
                        .font(.custom("Inter-SemiBold", size: 20))
                        .foregroundColor(.blackText)
                    
                    VStack(alignment: .leading) {
                        // Список приложений с количеством уведомлений
                        if detail.totalNotifications == 0 {
                            HStack {
                                Text("No data available")
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
                                        Text(appDetail.application.localizedDisplayName ?? "Application")
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
            ToolbarItem(placement: .automatic) {
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
                .font(.custom("Inter-SemiBold", size: 18))
                .foregroundColor(.blackText)
            Spacer()
            if chartType == .daily {
                Text("The last 7 days")
                    .font(.custom("Inter-Regular", size: 14))
                    .foregroundColor(.data)
            } else {
                HStack(spacing: 4) {
                    Text("Today,")
                    Text("\(getDateString())")
                }
                .font(.custom("Inter-Regular", size: 14))
                .foregroundColor(.data)
            }
        }
        .padding(.horizontal, 10)
    }
    
    private var dayChartView: some View {
        Chart(hourlyChartData) { item in
            BarMark(
                x: .value("Hour", Double(item.hour) + 0.4),
                y: .value("Seconds", item.duration)
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
                            .font(.custom("Inter-Regular", size: 12))
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
                            .font(.custom("Inter-Regular", size: 12))
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
//                x: .value("День", dataPoint.dateString),
//                y: .value("Секунды", dataPoint.duration)
                x: .value("Day", dataPoint.dateString),
                y: .value("Seconds", dataPoint.duration)
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
                            .font(.custom("Inter-Regular", size: 12))
                            .foregroundColor(.timestamps)
                            .padding(.trailing, 10)
                    }
                }
            }
        }
        .frame(height: 150)
    }
}
