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
                HStack(spacing: 4) {
                    Text("Today,")
                    Text("\(getDateString())")
                }
                .font(.custom("Inter-Regular", size: 14))
                .foregroundColor(.data)
            }
            .padding(.horizontal, 10)
            
            Chart(viewModel.hourlyData) { item in
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
            Text("No data for yesterday")
                .foregroundColor(.timestamps)
        } else {
            let diff = today - yesterday
            let percent = Int(abs((diff / yesterday) * 100))
            if diff > 0 {
                HStack(spacing: 4) {
                    Text("+ \(percent)%")
                    Text("compared to yesterday")
                }
                .foregroundColor(.redStat)
            } else if diff < 0 {
                HStack(spacing: 4) {
                    Text("- \(percent)%")
                    Text("compared to yesterday")
                }
                .foregroundColor(.greenStat)
            } else {
                Text("The same amount as yesterday")
                    .foregroundColor(.timestamps)
            }
        }
    }
}
