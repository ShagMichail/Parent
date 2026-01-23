//
//  WebUsageView.swift
//  Parent
//
//  Created by Michail Shagovitov on 23.12.2025.
//

import SwiftUI
import Charts
import FamilyControls

struct WebUsageView: View {
    let viewModel: WebReportViewModel
    @State private var selectedWebDetail: WebUsageDetail?
    
    var body: some View {
        ScrollView {
            VStack {
                // --- Блок "Экранное время" ---
                VStack(alignment: .leading, spacing: 10) {
                    Text("Screen time")
                        .font(.custom("Inter-SemiBold", size: 20))
                    
                    VStack(alignment: .leading, spacing: 12) {
                        headerView
                        if viewModel.isWeekView { weekChartView }
                        else { dayChartView }
                        
                        if !viewModel.isWeekView { comparisonView }
                    }
                    .padding(.vertical, 20)
                    .background(Color(.systemBackground))
                    .cornerRadius(20)
                }
                .padding(.bottom, 16)
                
                // --- Список сайтов ---
                webListView
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 80)
        }
        .background(.backgroundApps)
        .scrollIndicators(.hidden)
        .sheet(item: $selectedWebDetail) { detail in
            NavigationView {
                WebDetailView(
                    detail: detail,
                    chartType: viewModel.isWeekView ? .daily : .hourly
                )
            }
            .presentationDetents([.fraction(0.9)])
        }
        .onChange(of: viewModel) { _, _ in
            if selectedWebDetail != nil {
                print("Фильтр изменился, закрываем детальное окно...")
                selectedWebDetail = nil
            }
        }
    }
    
    
    // MARK: - Subviews
    
    // --- Заголовок ---
    private var headerView: some View {
        HStack {
            let durationToShow = viewModel.isWeekView ? viewModel.dailyData.reduce(0) { $0 + $1.duration } : viewModel.totalDuration
            
            Text(formatTotalDuration(durationToShow))
                .font(.custom("Inter-SemiBold", size: 18))
                .foregroundColor(.blackText)
            Spacer()
            if viewModel.isWeekView {
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
    
    // --- ГРАФИК НЕДЕЛИ (0 - 24 часа) ---
    private var weekChartView: some View {
        Chart {
            ForEach(viewModel.dailyData) { item in
                BarMark(
                    x: .value("Day", item.dateString),
                    y: .value("Seconds", item.duration)
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
                            .font(.custom("Inter-Regular", size: 12))
                            .foregroundColor(.timestamps)
                            .padding(.trailing, 10)
                    }
                }
            }
        }
        .frame(height: 150)
        .id("WeekChart")
    }
    
    private var dayChartView: some View {
        Chart {
            ForEach(viewModel.hourlyData) { item in
                BarMark(
                    x: .value("Hour", Double(item.hour) + 0.4),
                    y: .value("Seconds", item.duration)
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
        .id("DayChart")
    }
    
    // --- Сравнение ---
    @ViewBuilder
    private var comparisonView: some View {
        getComparisonText()
            .font(.custom("Inter-Medium", size: 14))
            .padding(.horizontal, 10)
    }
    
    // --- Список сайтов ---
    private var webListView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Sites visited")
                .font(.custom("Inter-SemiBold", size: 20))
                .foregroundColor(.blackText)
            
            VStack(spacing: 0) {
                ForEach(viewModel.websites) { detail in
                    Button(action: {
                        selectedWebDetail = detail
                    }) {
                        HStack {
                            Label(detail.token).labelStyle(.iconOnly)
                                .scaleEffect(1.2)
                            Label(detail.token).labelStyle(.titleOnly)
                                .font(.system(size: 16))
                                .foregroundColor(.blackText)
                                .lineLimit(1)
                            Spacer()
                            Text(formatTotalDuration(detail.totalDuration))
                                .font(.custom("Inter-Regular", size: 16))
                                .foregroundColor(.timestamps)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 20)
                        .padding(.horizontal, 10)
                    }
                    .buttonStyle(PlainButtonStyle())
                    if detail.id != viewModel.websites.last?.id {
                        Divider()
                            .padding(.horizontal, 10)
                    }
                }
                if viewModel.websites.isEmpty {
                    HStack {
                        Text("No data available")
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.leading)
                            .padding(.vertical, 20)
                            .padding(.horizontal, 10)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
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
