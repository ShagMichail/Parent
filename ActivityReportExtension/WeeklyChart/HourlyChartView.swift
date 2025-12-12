//
//  WeeklyChartView.swift
//  Parent
//
//  Created by Michail Shagovitov on 10.12.2025.
//

import SwiftUI
import Charts

import SwiftUI
import Charts

struct HourlyChartView: View {
    let viewModel: HourlyChartViewModel
        
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            HStack {
                Text(formatTotalDuration(viewModel.todayTotalDuration))
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.blackText)
                Spacer()
                Text("Сегодня, \(getDateString())")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(.data)
            }
            .padding(.horizontal, 10)
            
            Chart(viewModel.hourlyData) { item in
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
                        if let intValue = value.as(Int.self) {
                            Text("\(intValue):00")
                                .font(.system(size: 10, weight: .regular, design: .rounded))
                                .foregroundColor(.timestamps)
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .trailing, values: [0, 1800, 3600]) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let seconds = value.as(Int.self) {
                            Text("\(seconds / 60)")
                                .font(.system(size: 10, weight: .regular, design: .rounded))
                                .foregroundColor(.timestamps)
                                .padding(.trailing, 10)
                        }
                    }
                }
            }
            .frame(height: 120)
            
            getComparisonText()
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .padding(.horizontal, 10)
        }
        .padding(.vertical, 20)
        .background(Color.white)
        .cornerRadius(20)
    }
    
    
    @ViewBuilder
    private func getComparisonText() -> some View {
        let today = viewModel.todayTotalDuration
        let yesterday = viewModel.yesterdayTotalDuration
        
        if yesterday == 0 {
            Text("Нет данных за вчерашний день")
                .foregroundColor(.timestamps)
        } else {
            let difference = today - yesterday
            let percentage = yesterday > 0 ? (difference / yesterday) * 100 : 0
            let percentInt = Int(abs(percentage))
            
            if difference > 0 {
                Text("+ \(percentInt)% в сравнении со вчерашним днём")
                    .foregroundColor(.redStat)
            } else if difference < 0 {
                Text("- \(percentInt)% в сравнении со вчерашним днём")
                    .foregroundColor(.greenStat)
            } else {
                Text("Столько же, сколько вчера")
                    .foregroundColor(.timestamps)
            }
        }
    }
    
    private func formatTotalDuration(_ duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = .dropAll
        
        if duration < 60 {
            return "\(Int(duration)) сек"
        }
        
        formatter.allowedUnits = [.hour, .minute]
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "ru_RU")
        formatter.calendar = calendar
        return formatter.string(from: duration) ?? "0 мин"
    }
    
    private func getDateString() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM"
        return formatter.string(from: Date())
    }
}
