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
                    .font(.custom("Inter-SemiBold", size: 18))
                    .foregroundColor(.blackText)
                Spacer()
                Text("Сегодня, \(getDateString())")
                    .font(.custom("Inter-Regular", size: 14))
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
                                .font(.custom("Inter-Regular", size: 10))
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
                                .font(.custom("Inter-Regular", size: 10))
                                .foregroundColor(.timestamps)
                                .padding(.trailing, 10)
                        }
                    }
                }
            }
            .frame(height: 120)
            
            getComparisonText()
                .font(.custom("Inter-Regular", size: 14))
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
}
