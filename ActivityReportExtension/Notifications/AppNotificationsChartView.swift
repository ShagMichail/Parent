//
//  NotificationsChartView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 24.11.2025.
//

import SwiftUI
import Charts

struct AppNotificationsChartView: View {
    let appNotificationsData: AppNotificationsData
    @State private var isAllAppsExpanded = false
    @State private var refreshID = UUID()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Уведомления от приложений")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                
                if appNotificationsData.allApps.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "bell.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("Нет данных об уведомлениях")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        Text("Данные появятся когда приложения начнут отправлять уведомления")
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
                                Text("Всего уведомлений")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(appNotificationsData.totalNotifications)")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .leading) {
                                Text("Приложений с уведомлениями")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(appNotificationsData.allApps.count)")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "bell.badge.fill")
                                .font(.title2)
                                .foregroundColor(.orange)
                        }
                        
                        if appNotificationsData.allApps.count > 0 {
                            HStack {
                                StatView(
                                    title: "В среднем на приложение",
                                    value: "\(appNotificationsData.totalNotifications / appNotificationsData.allApps.count)",
                                    icon: "number.circle.fill",
                                    color: .blue
                                )
                                
                                Spacer()
                                
                                StatView(
                                    title: "Самое активное",
                                    value: "\(appNotificationsData.topApps.first?.notificationCount ?? 0)",
                                    icon: "crown.fill",
                                    color: .yellow
                                )
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.orange.opacity(0.1))
                    )
                    
                    VStack(spacing: 12) {
                        HStack {
                            Text("Топ приложений по уведомлениям")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chart.bar.fill")
                                .foregroundColor(.orange)
                        }
                        
                        Chart(appNotificationsData.topApps) { app in
                            BarMark(
                                x: .value("Уведомления", app.notificationCount),
                                y: .value("Приложение", app.appName)
                            )
                            .foregroundStyle(by: .value("Категория", app.category))
                            .annotation(position: .trailing) {
                                Text("\(app.notificationCount)")
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
                        Text("Все приложения с уведомлениями (\(appNotificationsData.allApps.count))")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        if appNotificationsData.allApps.count > 8 {
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    isAllAppsExpanded.toggle()
                                }
                            }) {
                                HStack(spacing: 4) {
                                    Text(isAllAppsExpanded ? "Свернуть" : "Показать все")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.orange)
                                    
                                    Image(systemName: "chevron.down")
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                        .rotationEffect(.degrees(isAllAppsExpanded ? 180 : 0))
                                }
                            }
                        }
                    }
                    .padding(.top, 8)
                    
                    LazyVStack(spacing: 8) {
                        let displayedApps = isAllAppsExpanded ?
                            appNotificationsData.allApps :
                            Array(appNotificationsData.allApps.prefix(8))
                        
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
                                    Image(systemName: getNotificationIcon(for: app.notificationCount))
                                        .font(.caption)
                                        .foregroundColor(getNotificationColor(for: app.notificationCount))
                                    
                                    Text("\(app.notificationCount)")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(getNotificationColor(for: app.notificationCount))
                                    
                                    Text("увед.")
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
                        
                        if !isAllAppsExpanded && appNotificationsData.allApps.count > 8 {
                            Text("+\(appNotificationsData.allApps.count - 8) приложений")
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
    
    private func getNotificationIcon(for count: Int) -> String {
        switch count {
        case 0: return "bell"
        case 1...10: return "bell.fill"
        case 11...30: return "bell.badge.fill"
        default: return "bell.and.waves.left.and.right.fill"
        }
    }
    
    private func getNotificationColor(for count: Int) -> Color {
        switch count {
        case 0: return .gray
        case 1...10: return .orange
        case 11...30: return .red
        default: return .purple
        }
    }
}
