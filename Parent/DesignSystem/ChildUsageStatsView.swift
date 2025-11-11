////
////  ChildUsageStatsView.swift
////  Parent
////
////  Created by Михаил Шаговитов on 10.11.2025.
////
//
//import SwiftUI
//
//struct ChildUsageStatsView: View {
//    let child: Child
//    @State private var selectedPeriod = 0
//    let periods = ["Сегодня", "Неделя", "Месяц"]
//    
//    // Мок-данные для демонстрации
//    private let mockUsageData: [String: Double] = [
//        "Игры": 2.5,
//        "Соцсети": 1.8,
//        "Видео": 1.2,
//        "Образование": 0.8,
//        "Другое": 0.5
//    ]
//    
//    var totalUsage: Double {
//        mockUsageData.values.reduce(0, +)
//    }
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 16) {
//            HStack {
//                Text("Статистика использования")
//                    .font(.headline)
//                
//                Spacer()
//                
//                Picker("Период", selection: $selectedPeriod) {
//                    ForEach(0..<periods.count, id: \.self) { index in
//                        Text(periods[index]).tag(index)
//                    }
//                }
//                .pickerStyle(SegmentedPickerStyle())
//                .frame(width: 200)
//            }
//            
//            // Общее время
//            VStack(spacing: 8) {
//                Text("Общее время использования")
//                    .font(.caption)
//                    .foregroundColor(.secondary)
//                
//                Text(formatTime(totalUsage * 3600))
//                    .font(.system(size: 32, weight: .bold))
//                    .foregroundColor(.primary)
//            }
//            .frame(maxWidth: .infinity)
//            .padding()
//            .background(Color.blue.opacity(0.1))
//            .cornerRadius(12)
//            
//            // Диаграмма по категориям
//            VStack(alignment: .leading, spacing: 12) {
//                Text("По категориям")
//                    .font(.subheadline)
//                    .fontWeight(.medium)
//                
//                ForEach(Array(mockUsageData.keys.sorted()), id: \.self) { category in
//                    if let time = mockUsageData[category] {
//                        UsageProgressRow(
//                            category: category,
//                            time: time,
//                            totalTime: totalUsage
//                        )
//                    }
//                }
//            }
//            
//            // Прогресс лимита
//            VStack(alignment: .leading, spacing: 8) {
//                HStack {
//                    Text("Использовано из лимита")
//                        .font(.subheadline)
//                        .fontWeight(.medium)
//                    
//                    Spacer()
//                    
//                    Text("\(Int(totalUsage))/\(Int(child.timeLimit / 3600)) ч")
//                        .font(.caption)
//                        .foregroundColor(.secondary)
//                }
//                
//                ProgressView(value: totalUsage, total: child.timeLimit / 3600)
//                    .progressViewStyle(LinearProgressViewStyle(tint: progressColor))
//                
//                Text(remainingTimeText)
//                    .font(.caption)
//                    .foregroundColor(remainingTimeColor)
//            }
//            .padding()
//            .background(Color(.systemGray6))
//            .cornerRadius(8)
//        }
//        .padding()
//        .background(Color(.systemBackground))
//        .cornerRadius(12)
//        .shadow(color: .gray.opacity(0.2), radius: 5)
//    }
//    
//    private var progressColor: Color {
//        let usagePercentage = totalUsage / (child.timeLimit / 3600)
//        if usagePercentage > 0.8 {
//            return .red
//        } else if usagePercentage > 0.6 {
//            return .orange
//        } else {
//            return .green
//        }
//    }
//    
//    private var remainingTimeText: String {
//        let remaining = (child.timeLimit / 3600) - totalUsage
//        if remaining > 0 {
//            return "Осталось \(formatTime(remaining * 3600))"
//        } else {
//            return "Лимит превышен на \(formatTime(abs(remaining) * 3600))"
//        }
//    }
//    
//    private var remainingTimeColor: Color {
//        let remaining = (child.timeLimit / 3600) - totalUsage
//        return remaining > 0 ? .secondary : .red
//    }
//    
//    private func formatTime(_ timeInterval: TimeInterval) -> String {
//        let hours = Int(timeInterval) / 3600
//        let minutes = (Int(timeInterval) % 3600) / 60
//        
//        if hours > 0 {
//            return "\(hours) ч \(minutes) мин"
//        } else {
//            return "\(minutes) мин"
//        }
//    }
//}
