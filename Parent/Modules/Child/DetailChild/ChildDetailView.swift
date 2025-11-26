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
    @EnvironmentObject var cloudKitManager: CloudKitManager
    let child: Child
    
    @State private var showingBlockProgress = false
    @State private var showingUnblockProgress = false
    
    var body: some View {
        Form {
            Section(header: Text("Мгновенные действия")) {
                Button("Заблокировать все") {
                    stateManager.sendBlockCommand(for: child.recordID)
                    showingBlockProgress = true
                }
                .tint(.red)
                .disabled(isCommandInProgress)
                
                Button("Разблокировать все") {
                    stateManager.sendUnblockCommand(for: child.recordID)
                    showingUnblockProgress = true
                }
                .tint(.green)
                .disabled(isCommandInProgress)
                
                if !activeCommands.isEmpty {
                    CommandProgressView(commands: activeCommands)
                }
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
        .overlay {
            if showingBlockProgress || showingUnblockProgress {
                CommandExecutionOverlay(
                    isShowing: showingBlockProgress ? $showingBlockProgress : $showingUnblockProgress,
                    commandType: showingBlockProgress ? "block_all_apps" : "unblock_all_apps",
                    childID: child.recordID
                )
            }
        }
        .onReceive(cloudKitManager.$pendingCommands) { _ in
            checkCommandCompletion()
        }
    }
    
    private func checkCommandCompletion() {
        let activeCommands = getActiveCommandsForChild()
        
        // Если нет активных команд, скрываем прогресс
        if activeCommands.isEmpty {
            showingBlockProgress = false
            showingUnblockProgress = false
        }
    }
    
    private var isCommandInProgress: Bool {
        !getActiveCommandsForChild().isEmpty
    }
    
    private var activeCommands: [CommandStatus] {
        getActiveCommandsForChild()
    }
    
    private func getActiveCommandsForChild() -> [CommandStatus] {
        stateManager.getActiveCommands(for: child.recordID)
    }
}
