//
//  UsageStatsView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 11.11.2025.
//

import SwiftUI
import DeviceActivity

struct UsageStatsView: View {
    let child: FamilyMember
    @EnvironmentObject var familyManager: FamilyManager
    
    @State private var usageStats: DeviceUsageStats?
    @State private var isLoading = true
    @State private var timeRange: TimeRange = .today
    
    enum TimeRange: String, CaseIterable {
        case today = "Сегодня"
        case week = "Неделя"
        case month = "Месяц"
        
        var dateRange: DateInterval {
            let calendar = Calendar.current
            let now = Date()
            
            switch self {
            case .today:
                return DateInterval(start: calendar.startOfDay(for: now), end: now)
            case .week:
                let weekAgo = calendar.date(byAdding: .day, value: -7, to: now)!
                return DateInterval(start: weekAgo, end: now)
            case .month:
                let monthAgo = calendar.date(byAdding: .month, value: -1, to: now)!
                return DateInterval(start: monthAgo, end: now)
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Сегментированный контрол для выбора периода
                Picker("Период", selection: $timeRange) {
                    ForEach(TimeRange.allCases, id: \.self) { range in
                        Text(range.rawValue).tag(range)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .onChange(of: timeRange) { _ in
                    loadUsageStats()
                }
                
                if isLoading {
                    ProgressView("Загрузка статистики...")
                        .frame(height: 200)
                } else if let stats = usageStats {
                    // Основная статистика
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        StatCard(
                            title: "Общее время",
                            value: formatTime(stats.totalScreenTime),
                            color: .blue,
                            icon: "clock"
                        )
                        
                        StatCard(
                            title: "Чаще всего",
                            value: stats.mostUsedApp ?? "Нет данных",
                            color: .green,
                            icon: "star"
                        )
                        
                        StatCard(
                            title: "Сессии",
                            value: "\(stats.sessionCount)",
                            color: .orange,
                            icon: "play"
                        )
                        
                        StatCard(
                            title: "Превышения",
                            value: "\(stats.limitExceedances)",
                            color: .red,
                            icon: "exclamationmark.triangle"
                        )
                    }
                    .padding(.horizontal)
                    
                    // График использования по дням
                    if !stats.dailyUsage.isEmpty {
                        DailyUsageChart(dailyUsage: stats.dailyUsage)
                            .padding(.horizontal)
                    }
                    
                    // Список приложений
                    AppUsageList(mostUsedApps: stats.mostUsedApps)
                        .padding(.horizontal)
                    
                } else {
                    Text("Статистика недоступна")
                        .foregroundColor(.secondary)
                        .frame(height: 200)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Статистика \(child.name)")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadUsageStats()
        }
        .refreshable {
            loadUsageStats()
        }
    }
    
    private func loadUsageStats() {
        isLoading = true
        
        Task {
            // В реальном приложении здесь будет загрузка из DeviceActivity
            // Пока используем демо-данные
            let demoStats = createDemoStats(for: timeRange)
            
            try? await Task.sleep(nanoseconds: 1_000_000_000) // Имитация загрузки
            
            await MainActor.run {
                usageStats = demoStats
                isLoading = false
            }
        }
    }
    
    private func createDemoStats(for range: TimeRange) -> DeviceUsageStats {
        // Демо-данные - в реальном приложении будут из DeviceActivity
        return DeviceUsageStats(
            totalScreenTime: Double.random(in: 1...4) * 3600, // 1-4 часа
            mostUsedApps: [
                "YouTube": Double.random(in: 0.5...2) * 3600,
                "TikTok": Double.random(in: 0.3...1.5) * 3600,
                "Minecraft": Double.random(in: 0.2...1) * 3600,
                "Safari": Double.random(in: 0.1...0.5) * 3600
            ],
            sessionCount: Int.random(in: 10...30),
            limitExceedances: Int.random(in: 0...3),
            dailyUsage: createDemoDailyUsage(),
            lastUpdated: Date()
        )
    }
    
    private func createDemoDailyUsage() -> [DailyUsage] {
        let calendar = Calendar.current
        var usage: [DailyUsage] = []
        
        for day in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: -day, to: Date()) else { continue }
            usage.append(DailyUsage(
                date: date,
                totalTime: Double.random(in: 0.5...3) * 3600,
                appUsage: [:]
            ))
        }
        
        return usage.reversed()
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60
        return "\(hours)ч \(minutes)м"
    }
}

