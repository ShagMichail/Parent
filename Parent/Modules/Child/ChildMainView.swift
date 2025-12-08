//
//  ChildMainView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 10.11.2025.
//

import SwiftUI

struct ChildMainView: View {
    @State private var remainingTime: TimeInterval = 2 * 3600
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                VStack(spacing: 16) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                    
//                    Text(familyManager.currentUser?.name ?? "Ребенок")
//                        .font(.title2)
//                        .fontWeight(.bold)
                    
                    Text("Детский режим")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding()
                
                // Оставшееся время
                VStack(spacing: 12) {
                    Text("Оставшееся время")
                        .font(.headline)
                    
                    Text(formatTime(remainingTime))
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.blue)
                    
                    ProgressView(value: remainingTime, total: 2 * 3600)
                        .progressViewStyle(LinearProgressViewStyle())
                        .padding(.horizontal, 40)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Доступные приложения
                VStack(alignment: .leading, spacing: 12) {
                    Text("Доступные приложения")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    Text("Список разрешенных приложений")
                        .foregroundColor(.secondary)
                        .padding()
                }
                
                Spacer()
                
                // Кнопка запроса времени
                Button("Запросить дополнительное время") {
                    requestAdditionalTime()
                }
                .buttonStyle(SecondaryButtonStyle())
                .padding()
            }
            .navigationTitle("Мой аккаунт")
        }
    }
    
    private func requestAdditionalTime() {
        print("Запрос дополнительного времени")
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60
        return "\(hours)ч \(minutes)м"
    }
}
