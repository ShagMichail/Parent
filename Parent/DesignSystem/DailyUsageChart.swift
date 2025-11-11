//
//  DailyUsageChart.swift
//  Parent
//
//  Created by Михаил Шаговитов on 11.11.2025.
//

import SwiftUI

struct DailyUsageChart: View {
    let dailyUsage: [DailyUsage]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Использование по дням")
                .font(.headline)
            
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(dailyUsage, id: \.date) { usage in
                    VStack(spacing: 4) {
                        // График в виде столбцов
                        Rectangle()
                            .fill(Color.blue)
                            .frame(
                                width: 20,
                                height: CGFloat(usage.totalTime / 3600) * 20 // Масштабируем
                            )
                            .cornerRadius(4)
                        
                        Text(formatDay(usage.date))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(height: 120)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func formatDay(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM"
        return formatter.string(from: date)
    }
}
