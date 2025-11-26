//
//  PickupsChartView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 25.11.2025.
//

import SwiftUI
import Charts

struct AppPickupsChartView: View {
    let appPickupsData: AppPickupsData
    @State private var isAllAppsExpanded = false
    @State private var refreshID = UUID()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Прямые переходы к приложениям")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("Когда вы сразу открываете приложение после поднятия телефона")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        refreshData()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.headline)
                            .foregroundColor(.purple)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                if appPickupsData.allApps.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "hand.tap")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("Нет данных о переходах")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        Text("Данные появятся когда вы будете сразу открывать приложения после поднятия телефона")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, minHeight: 300)
                    .padding()
                } else {
                    VStack(spacing: 12) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Всего прямых переходов")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(appPickupsData.totalPickups)")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .leading) {
                                Text("Приложений с переходами")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(appPickupsData.allApps.count)")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "hand.tap.fill")
                                .font(.title2)
                                .foregroundColor(.purple)
                        }
                        
                        if appPickupsData.allApps.count > 0 {
                            HStack {
                                StatView(
                                    title: "В среднем на приложение",
                                    value: "\(appPickupsData.totalPickups / appPickupsData.allApps.count)",
                                    icon: "number.circle.fill",
                                    color: .blue
                                )
                                
                                Spacer()
                                
                                StatView(
                                    title: "Самое частое",
                                    value: "\(appPickupsData.topApps.first?.pickupCount ?? 0)",
                                    icon: "star.fill",
                                    color: .yellow
                                )
                                
                                Spacer()
                                
                                StatView(
                                    title: "Привычка",
                                    value: "\(calculateHabitStrength())%",
                                    icon: "brain.head.profile",
                                    color: .green
                                )
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.purple.opacity(0.1))
                    )
                    
                    VStack(spacing: 12) {
                        HStack {
                            Text("Топ приложений по прямым переходам")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .foregroundColor(.purple)
                        }
                        
                        Chart(appPickupsData.topApps) { app in
                            BarMark(
                                x: .value("Переходы", app.pickupCount),
                                y: .value("Приложение", app.appName)
                            )
                            .foregroundStyle(by: .value("Категория", app.category))
                            .annotation(position: .trailing) {
                                Text("\(app.pickupCount)")
                                    .font(.caption2)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                            }
                        }
                        .frame(height: 250)
                        .chartYAxis {
                            AxisMarks { value in
                                AxisValueLabel {
                                    if let appName = value.as(String.self) {
                                        Text(appName)
                                            .font(.caption)
                                    }
                                }
                            }
                        }
                    }
                    
                    HStack {
                        Text("Все приложения с переходами (\(appPickupsData.allApps.count))")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        if appPickupsData.allApps.count > 8 {
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    isAllAppsExpanded.toggle()
                                }
                            }) {
                                HStack(spacing: 4) {
                                    Text(isAllAppsExpanded ? "Свернуть" : "Показать все")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.purple)
                                    
                                    Image(systemName: "chevron.down")
                                        .font(.caption)
                                        .foregroundColor(.purple)
                                        .rotationEffect(.degrees(isAllAppsExpanded ? 180 : 0))
                                }
                            }
                        }
                    }
                    .padding(.top, 8)
                    
                    LazyVStack(spacing: 8) {
                        let displayedApps = isAllAppsExpanded ?
                            appPickupsData.allApps :
                            Array(appPickupsData.allApps.prefix(8))
                        
                        ForEach(displayedApps) { app in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(app.appName)
                                        .font(.headline)
                                    Text(app.category)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                HStack(spacing: 6) {
                                    Image(systemName: getPickupIcon(for: app.pickupCount))
                                        .font(.caption)
                                        .foregroundColor(getPickupColor(for: app.pickupCount))
                                    
                                    Text("\(app.pickupCount)")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(getPickupColor(for: app.pickupCount))
                                    
                                    Text(app.pickupCount == 1 ? "переход" : "переходов")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(.systemGray6))
                            )
                        }
                        
                        if !isAllAppsExpanded && appPickupsData.allApps.count > 8 {
                            Text("+\(appPickupsData.allApps.count - 8) приложений")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                        }
                    }
                }
            }
            .padding()
        }
        .id(refreshID)
        .refreshable {
            await refreshDataAsync()
        }
    }
    
    private func refreshData() {
        withAnimation(.spring()) {
            refreshID = UUID()
        }
    }
    
    private func refreshDataAsync() async {
        try? await Task.sleep(nanoseconds: 500_000_000)
        await MainActor.run {
            refreshData()
        }
    }
    
    private func calculateHabitStrength() -> Int {
        guard appPickupsData.totalPickups > 0 else { return 0 }
        
        let topThreePickups = appPickupsData.topApps.prefix(3).reduce(0) { $0 + $1.pickupCount }
        return Int((Double(topThreePickups) / Double(appPickupsData.totalPickups)) * 100)
    }
    
    private func getPickupIcon(for count: Int) -> String {
        switch count {
        case 0: return "hand.tap"
        case 1...5: return "hand.tap.fill"
        case 6...15: return "hand.point.up.left.fill"
        default: return "figure.walk.motion"
        }
    }
    
    private func getPickupColor(for count: Int) -> Color {
        switch count {
        case 0: return .gray
        case 1...5: return .purple
        case 6...15: return .indigo
        default: return .red
        }
    }
}
