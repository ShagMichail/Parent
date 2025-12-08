//
//  CombinedActivityView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 24.11.2025.
//

import SwiftUI
import Charts

struct CombinedActivityView: View {
    let appUsageData: AppUsageData
    let totalActivity: String
    @State private var isTotalActivityExpanded = false
    @State private var isAllAppsExpanded = false
    @State private var refreshID = UUID()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Статистика использования")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("Активность приложений за выбранный период")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                if appUsageData.allApps.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "chart.pie.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("Нет данных об использовании")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        Text("Данные появятся когда вы начнете использовать приложения")
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
                                Text("Общее экранное время")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(totalActivity)
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .leading) {
                                Text("Приложений использовано")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(appUsageData.allApps.count)")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "clock.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                        
                        HStack {
                            StatView(
                                title: "В среднем на приложение",
                                value: formatDuration(averageTimePerApp()),
                                icon: "timer",
                                color: .green
                            )
                            
                            Spacer()
                            
                            StatView(
                                title: "Самое используемое",
                                value: formatDuration(appUsageData.topFiveApps.first?.duration ?? 0),
                                icon: "crown.fill",
                                color: .orange
                            )
                            
                            Spacer()
                            
                            StatView(
                                title: "Продуктивность",
                                value: "\(calculateProductivityPercentage())%",
                                icon: "chart.bar.fill",
                                color: .purple
                            )
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.blue.opacity(0.1))
                    )
                    
                    VStack(spacing: 12) {
                        HStack {
                            Text("Топ-5 приложений по времени")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chart.bar.fill")
                                .foregroundColor(.blue)
                        }
                        
                        Chart(appUsageData.topFiveApps) { app in
                            BarMark(
                                x: .value("Время", app.duration),
                                y: .value("Приложение", app.appName)
                            )
                            .foregroundStyle(by: .value("Категория", app.category))
                            .annotation(position: .trailing) {
                                Text(formatDuration(app.duration))
                                    .font(.caption2)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                            }
                        }
                        .frame(height: 200)
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
                        Text("Все приложения (\(appUsageData.allApps.count))")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        if appUsageData.allApps.count > 8 {
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    isAllAppsExpanded.toggle()
                                }
                            }) {
                                HStack(spacing: 4) {
                                    Text(isAllAppsExpanded ? "Свернуть" : "Показать все")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.blue)
                                    
                                    Image(systemName: "chevron.down")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                        .rotationEffect(.degrees(isAllAppsExpanded ? 180 : 0))
                                }
                            }
                        }
                    }
                    .padding(.top, 8)
                    
                    LazyVStack(spacing: 8) {
                        let displayedApps = isAllAppsExpanded ?
                            appUsageData.allApps :
                            Array(appUsageData.allApps.prefix(8))
                        
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
                                    Image(systemName: getUsageIcon(for: app.duration))
                                        .font(.caption)
                                        .foregroundColor(getUsageColor(for: app.duration))
                                    
                                    Text(formatDuration(app.duration))
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(getUsageColor(for: app.duration))
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(.systemGray6))
                            )
                        }
                        
                        if !isAllAppsExpanded && appUsageData.allApps.count > 8 {
                            Text("+\(appUsageData.allApps.count - 8) приложений")
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
    
    private func averageTimePerApp() -> TimeInterval {
        guard !appUsageData.allApps.isEmpty else { return 0 }
        let total = appUsageData.allApps.reduce(0) { $0 + $1.duration }
        return total / Double(appUsageData.allApps.count)
    }
    
    private func totalDuration() -> TimeInterval {
        appUsageData.allApps.reduce(0) { $0 + $1.duration }
    }
    
    private func calculateProductivityPercentage() -> Int {
        let productiveCategories: Set<String> = ["Productivity", "Browsers", "Communication"]
        let productiveTime = appUsageData.allApps
            .filter { productiveCategories.contains($0.category) }
            .reduce(0) { $0 + $1.duration }
        
        guard totalDuration() > 0 else { return 0 }
        return Int((productiveTime / totalDuration()) * 100)
    }
    
    private func getCategoryData() -> [CategoryData] {
        var categoryDict: [String: TimeInterval] = [:]
        
        for app in appUsageData.allApps {
            categoryDict[app.category, default: 0] += app.duration
        }
        
        return categoryDict.map { name, duration in
            CategoryData(name: name, duration: duration)
        }.sorted { $0.duration > $1.duration }
    }
    
    private func getUsageIcon(for duration: TimeInterval) -> String {
        switch duration {
        case 0..<300:
            return "timer"
        case 300..<1800:
            return "clock.fill"
        case 1800..<3600:
            return "desktopcomputer"
        default:
            return "clock.badge.checkmark.fill"
        }
    }
    
    private func getUsageColor(for duration: TimeInterval) -> Color {
        switch duration {
        case 0..<300:
            return .green
        case 300..<1800:
            return .blue
        case 1800..<3600:
            return .orange
        default:
            return .red
        }
    }
    
    private func colorForCategory(_ category: String) -> Color {
        switch category {
        case "Social Media": return .red
        case "Games": return .blue
        case "Browsers": return .green
        case "Communication": return .orange
        case "Entertainment": return .purple
        case "Productivity": return .indigo
        default: return .gray
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = .dropAll
        return formatter.string(from: duration) ?? "0s"
    }
}
