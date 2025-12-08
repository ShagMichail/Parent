//
//  LocationInfoCard.swift
//  Parent
//
//  Created by Михаил Шаговитов on 02.12.2025.
//

import SwiftUI

struct LocationInfoCard: View {
    let location: ChildLocation
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("Текущее местоположение")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack {
                    Image(systemName: "clock")
                        .font(.caption2)
                    
                    Text(location.timestamp, style: .time)
                        .font(.caption)
                }
                .foregroundColor(.secondary)
                
                if let address = location.deviceName {
                    Text(address)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 6) {
                if let battery = location.batteryLevel {
                    HStack(spacing: 4) {
                        Image(systemName: battery > 0.2 ? "battery.100" : "battery.25")
                            .foregroundColor(battery > 0.2 ? .green : .red)
                        
                        Text("\(Int(battery * 100))%")
                            .font(.caption)
                    }
                }
                
                if location.isCharging == true {
                    Label("Заряжается", systemImage: "bolt.fill")
                        .font(.caption2)
                        .foregroundColor(.green)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.blue.opacity(0.05))
        )
    }
}

