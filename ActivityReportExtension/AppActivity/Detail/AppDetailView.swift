//
//  AppDetailView.swift
//  Parent
//
//  Created by Michail Shagovitov on 17.12.2025.
//

import SwiftUI
import FamilyControls
import Charts
import ManagedSettings

struct AppDetailView: View {
    let detail: AppUsageDetail
    let chartType: ChartDetailType
    
    @State private var isBlocked = false
    @State private var isBlockButtonLoading = false
    
    private let store = ManagedSettingsStore()
    
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
                VStack(alignment: .leading, spacing: 10) {
                    Text("Screen time")
                        .font(.custom("Inter-SemiBold", size: 20))
                        .foregroundColor(.blackText)
                    
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
                .padding(.horizontal, 20)
                
                AppInfoCardView(detail: detail)
            }
            .padding(.bottom, 20)
        }
        .scrollIndicators(.hidden)
        .background(.backgroundApps)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: 8) {
                    Label(detail.token)
                        .labelStyle(.iconOnly)
                        .frame(width: 24, height: 24)
                    
                    Label(detail.token)
                        .labelStyle(.titleOnly)
                        .font(.system(size: 16))
                        .foregroundColor(.blackText)
                }
            }
        }
    }
    
    
    // проверить берется ли информация по доменам из других браущером кроме Safari
    // после статуса онлайн добавить кнопку обновления (стрелку)
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
                x: .value("Hour", item.hour),
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
