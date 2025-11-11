//
//  ChildInfoCard.swift
//  Parent
//
//  Created by Михаил Шаговитов on 11.11.2025.
//

import SwiftUI

struct ChildInfoCard: View {
    let child: FamilyMember  // Изменили на FamilyMember
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading) {
                    Text(child.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(child.appleId)  // Используем appleId вместо deviceId
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    Text(child.type.description)  // Показываем тип участника
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Circle()
                        .fill(isOnline ? Color.green : Color.gray)  // Вычисляемое свойство
                        .frame(width: 12, height: 12)
                    
                    Text(isOnline ? "В сети" : "Не в сети")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack {
                StatView(title: "Тип", value: child.type.description)
                
                StatView(title: "Устройство", value: deviceStatus)
                
                StatView(title: "Детей", value: "\(child.children.count)")
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // Вычисляемое свойство для статуса онлайн
    private var isOnline: Bool {
        // Здесь можно добавить реальную логику определения онлайн статуса
        // Пока используем наличие deviceId как индикатор
        return child.deviceId != nil
    }
    
    // Статус устройства
    private var deviceStatus: String {
        return child.deviceId != nil ? "Есть" : "Нет"
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60
        return "\(hours)ч \(minutes)м"
    }
}
