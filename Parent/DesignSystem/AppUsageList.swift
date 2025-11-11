//
//  AppUsageList.swift
//  Parent
//
//  Created by Михаил Шаговитов on 11.11.2025.
//

import SwiftUI

struct AppUsageList: View {
    let mostUsedApps: [String: TimeInterval]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Часто используемые приложения")
                .font(.headline)
            
            LazyVStack(spacing: 8) {
                ForEach(Array(mostUsedApps.sorted(by: { $0.value > $1.value }).prefix(5)), id: \.key) { app, time in
                    HStack {
                        Text(app)
                            .font(.body)
                        
                        Spacer()
                        
                        Text(formatTime(time))
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60
        if hours > 0 {
            return "\(hours)ч \(minutes)м"
        } else {
            return "\(minutes)м"
        }
    }
}
