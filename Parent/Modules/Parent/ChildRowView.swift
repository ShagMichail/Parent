//
//  ChildRowView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 10.11.2025.
//

import SwiftUI

struct ChildRowView: View {
    let child: FamilyMember  // Изменили на FamilyMember
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(child.name)
                    .font(.headline)
                
                if let deviceId = child.deviceId {
                    Text(deviceId)
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text("Нет устройства")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Circle()
                        .fill(isOnline ? Color.green : Color.gray)  // Вычисляемое свойство
                        .frame(width: 8, height: 8)
                    
                    Text(isOnline ? "В сети" : "Не в сети")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(child.type.description)  // Показываем тип участника
                    .font(.caption)
                    .foregroundColor(.blue)
                
                if !child.children.isEmpty {
                    Text("Детей: \(child.children.count)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    // Вычисляемое свойство для статуса онлайн
    private var isOnline: Bool {
        // Здесь нужно добавить логику определения онлайн статуса
        // Пока заглушка - можно сделать на основе deviceId
        return child.deviceId != nil
    }
}
