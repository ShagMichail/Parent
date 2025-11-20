//
//  QuickChildActionsView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 12.11.2025.
//

import SwiftUI

struct QuickChildActionsView: View {
    let child: FamilyMember
    @Binding var showingRestrictions: Bool
    @Binding var showingTimeLimit: Bool
    @EnvironmentObject var parentManager: FamilyManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Быстрые действия")
                .font(.headline)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    // Блокировка устройства
//                    ActionButton(
//                        title: child.isDeviceBlocked ? "Разблокировать" : "Заблокировать",
//                        icon: child.isDeviceBlocked ? "lock.open" : "lock",
//                        color: child.isDeviceBlocked ? .green : .red
//                    ) {
//                        toggleDeviceBlock()
//                    }
                    
                    // Ограничения приложений
                    ActionButton(
                        title: "Ограничения",
                        icon: "hand.raised",
                        color: .orange
                    ) {
                        showingRestrictions = true
                    }
                    
                    // Лимит времени
                    ActionButton(
                        title: "Время",
                        icon: "clock",
                        color: .blue
                    ) {
                        showingTimeLimit = true
                    }
                    
                    // Пауза использования
//                    ActionButton(
//                        title: child.isPaused ? "Возобновить" : "Пауза",
//                        icon: child.isPaused ? "play" : "pause",
//                        color: .purple
//                    ) {
//                        togglePause()
//                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private func toggleDeviceBlock() {
        // Реализация блокировки устройства
//        parentManager.toggleDeviceBlock(for: child.id)
    }
    
    private func togglePause() {
        // Реализация паузы использования
//        parentManager.togglePause(for: child.id)
    }
}

struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 80, height: 80)
            .background(color)
            .cornerRadius(12)
        }
    }
}
