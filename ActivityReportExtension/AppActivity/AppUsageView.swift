//
//  CombinedActivityView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 24.11.2025.
//

import SwiftUI
import Charts

struct AppUsageView: View {
    let viewModel: ActivityReportViewModel
    
    var body: some View {
        ScrollView {
            VStack {
                
                // --- Блок "Экранное время" ---
                VStack(alignment: .leading, spacing: 10) {
                    Text("Экранное время")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(red: 0.12, green: 0.16, blue: 0.22)) // .blackText
                    
                    VStack(alignment: .leading, spacing: 12) {
                        
                        // Заголовок карточки
                        HStack {
                            Text(formatTotalDuration(viewModel.totalDuration))
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(red: 0.12, green: 0.16, blue: 0.22))
                            Spacer()
                            // Если неделя - пишем "За неделю", если день - дату
                            Text(viewModel.isWeekView ? "За последние 7 дней" : "Сегодня, \(getDateString())")
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 10)
                        
                        // --- ЛОГИКА ПЕРЕКЛЮЧЕНИЯ ГРАФИКОВ ---
                        if viewModel.isWeekView {
                            // === ГРАФИК НЕДЕЛИ ===
                            Chart(viewModel.dailyData) { item in
                                BarMark(
                                    x: .value("День", item.weekday), // Подпись: Пн, Вт...
                                    y: .value("Секунды", item.duration)
                                )
                                .foregroundStyle(Color.accentColor)
                                .cornerRadius(3)
                            }
                            // 1. Шкала Y до 24 часов (в секундах 86400)
                            .chartYScale(domain: 0...86400)
                            .chartYAxis {
                                // Метки: 0, 6ч, 12ч, 18ч, 24ч (умножаем часы на 3600)
                                AxisMarks(position: .trailing, values: [0, 21600, 43200, 64800, 86400]) { value in
                                    AxisGridLine()
                                    AxisValueLabel {
                                        if let seconds = value.as(Int.self) {
                                            // Делим на 3600, чтобы получить часы
                                            Text("\(seconds / 3600) ч")
                                                .font(.system(size: 10, weight: .regular, design: .rounded))
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                            }
                            .chartXAxis {
                                AxisMarks { value in
                                    AxisValueLabel()
                                        .font(.system(size: 10, weight: .regular, design: .rounded))
                                        .foregroundStyle(.gray)
                                }
                            }
                            .frame(height: 150) // Чуть повыше для недели
                            
                        } else {
                            // === ГРАФИК ДНЯ (Твой старый идеальный) ===
                            Chart(viewModel.hourlyData) { item in
                                BarMark(
                                    x: .value("Час", item.hour),
                                    y: .value("Секунды", item.duration)
                                )
                                .foregroundStyle(Color.accentColor)
                                .cornerRadius(3)
                            }
                            .chartXScale(domain: 0...24)
                            .chartYScale(domain: 0...3600) // До 60 минут
                            .chartXAxis {
                                AxisMarks(values: [0, 6, 12, 18, 24]) { value in
                                    AxisValueLabel {
                                        if let intValue = value.as(Int.self) {
                                            Text("\(intValue):00")
                                                .font(.system(size: 10, weight: .regular, design: .rounded))
                                                .foregroundColor(.gray)
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
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                            }
                            .frame(height: 120)
                        }
                        
                    }
                    .padding(.vertical, 20)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
                }
                .padding(.bottom, 16)
                
                // --- СПИСОК ПРИЛОЖЕНИЙ ---
                // (Оставляем как было, код идентичен)
                VStack(alignment: .leading, spacing: 10) {
                    Text("Используемые приложения")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(red: 0.12, green: 0.16, blue: 0.22))
                    
                    VStack(spacing: 0) {
                        ForEach(viewModel.apps.prefix(10)) { app in // Ограничим 10 приложениями
                            HStack {
                                Label(app.token)
                                    .labelStyle(.iconOnly)
                                    .scaleEffect(1.2)
                                Label(app.token)
                                    .labelStyle(.titleOnly)
                                    .font(.system(size: 16, weight: .regular, design: .rounded))
                                    .foregroundColor(.black)
                                    .lineLimit(1)
                                Spacer()
                                Text(formatTotalDuration(app.duration))
                                    .font(.system(size: 16, weight: .regular, design: .rounded))
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 16) // Чуть компактнее
                            .padding(.horizontal, 16)
                            
                            if app.id != viewModel.apps.prefix(10).last?.id {
                                Divider().padding(.leading, 60)
                            }
                        }
                        if viewModel.apps.isEmpty {
                            Text("Нет данных").padding().foregroundColor(.gray)
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(.backgroundApps)
        .scrollIndicators(.hidden)
    }
    
    // Хелперы
    private func getDateString() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM"
        return formatter.string(from: Date())
    }
    
    private func formatTotalDuration(_ duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = .dropAll
        if duration < 60 { return "\(Int(duration)) сек" }
        formatter.allowedUnits = [.hour, .minute]
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "ru_RU")
        formatter.calendar = calendar
        return formatter.string(from: duration) ?? "0 мин"
    }
}
