//
//  Untitled.swift
//  Parent
//
//  Created by Михаил Шаговитов on 10.11.2025.
//

import SwiftUI
import DeviceActivity

struct ChildDetailView: View {
    @EnvironmentObject var stateManager: AuthenticationManager
    let child: Child
    
    var body: some View {
        Form {
            Section(header: Text("Мгновенные действия")) {
                Button("Заблокировать все") {
                    stateManager.sendBlockCommand(for: child.recordID)
                }
                .tint(.red)

                Button("Разблокировать все") {
                    stateManager.sendUnblockCommand(for: child.recordID)
                }
                .tint(.green)
            }
            
            // Секция для перехода на другие экраны
            Section(header: Text("Отчеты и Настройки")) {
                NavigationLink(destination: ChildActivityReportView(childName: child.name)) {
                    HStack(spacing: 15) {
                        Image(systemName: "chart.bar.xaxis")
                            .font(.title2)
                            .foregroundColor(.accentColor)
                        Text("Статистика использования")
                    }
                }
                
                NavigationLink(destination: NotificationReportView(childName: child.name)) {
                    HStack(spacing: 15) {
                        Image(systemName: "chart.bar.xaxis")
                            .font(.title2)
                            .foregroundColor(.accentColor)
                        Text("Статистика уведомлений")
                    }
                }
                
                NavigationLink(destination: PickupsReportView(childName: child.name)) {
                    HStack(spacing: 15) {
                        Image(systemName: "chart.bar.xaxis")
                            .font(.title2)
                            .foregroundColor(.accentColor)
                        Text("Статистика поднятий")
                    }
                }
            }
        }
        .navigationTitle(child.name)
    }
}
