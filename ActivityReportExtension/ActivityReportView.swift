//
//  ActivityReportView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 14.11.2025.
//

import SwiftUI
import DeviceActivity
import Charts

struct ActivityReportView: View {
    // Расширение передаст нам "контекст" - это и есть наши реальные данные
    let context: DeviceActivityReport.Context
    
    // Состояния для хранения обработанных РЕАЛЬНЫХ данных
    @State private var totalScreenTime: TimeInterval = 0
    @State private var topApps: [AppUsage] = []
    @State private var topCategories: [CategoryUsage] = []
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Экранное время")
                .font(.largeTitle.bold())
                .padding(.bottom)
            
            Text("Всего: \(formatTime(totalScreenTime))")
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.bottom)
            
            Text("Самые используемые").font(.title2.bold())
            
            // График для приложений
            Chart(topApps) { app in
                BarMark(
                    x: .value("Время", app.duration / 60), // в минутах
                    y: .value("Приложение", app.appName)
                )
                .foregroundStyle(by: .value("Приложение", app.appName))
            }
            .chartLegend(.hidden)
            .frame(height: 200)
            
            Spacer()
        }
        .padding()
        .onAppear(perform: processReportData) // При появлении экрана обрабатываем данные
    }
    
    /// Обрабатывает РЕАЛЬНЫЕ данные из контекста отчета.
    private func processReportData() {
        // Извлекаем реальные данные из контекста.
        // `activitySegments` - это массив интервалов активности.
//        let reportSegments = context.activitySegments
        
        // Считаем общее время
//        self.totalScreenTime = reportSegments.reduce(0) { $0 + $1.totalActivityDuration }
//        
//        // --- Обработка данных по приложениям ---
//        let usageByApp = Dictionary(grouping: reportSegments, by: { $0.application })
//        let summarizedApps = usageByApp.map { (appToken, segments) in
//            let totalDuration = segments.reduce(0) { $0 + $1.totalActivityDuration }
//            return AppUsage(
//                appName: appToken.localizedDisplayName ?? "Неизвестно",
//                duration: totalDuration,
//                bundleId: appToken.bundleIdentifier ?? ""
//            )
//        }
//        // Сортируем и берем топ-5
//        self.topApps = Array(summarizedApps.sorted { $0.duration > $1.duration }.prefix(5))
//        
//        // --- Обработка данных по категориям (аналогично) ---
//        let usageByCategory = Dictionary(grouping: reportSegments, by: { $0.category })
//        let summarizedCategories = usageByCategory.map { (categoryToken, segments) in
//            let totalDuration = segments.reduce(0) { $0 + $1.totalActivityDuration }
//            return CategoryUsage(
//                categoryName: categoryToken.localizedDisplayName ?? "Неизвестно",
//                duration: totalDuration
//            )
//        }
//        self.topCategories = Array(summarizedCategories.sorted { $0.duration > $1.duration }.prefix(5))
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .full
        return formatter.string(from: timeInterval) ?? "0 минут"
    }
}
