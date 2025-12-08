////
////  Untitled.swift
////  Parent
////
////  Created by Михаил Шаговитов on 10.11.2025.
////
//
//import SwiftUI
//import DeviceActivity
//
//struct ChildDetailView: View {
//    @EnvironmentObject var authManager: AuthenticationManager
//    @EnvironmentObject var cloudKitManager: CloudKitManager
//    let child: Child
//    
//    @State private var isBlocked = false
//    
//    @State private var showingBlockProgress = false
//    @State private var showingUnblockProgress = false
//    
//    var body: some View {
//        Form {
//            Section(header: Text("Управление доступом")) {
//                Button(action: toggleBlock) {
//                    HStack {
//                        Image(systemName: isBlocked ? "lock.open.fill" : "lock.fill")
//                            .symbolEffect(.bounce, value: isBlocked)
//                        
//                        Text(isBlocked ? "Разблокировать устройство" : "Заблокировать устройство")
//                            .fontWeight(.medium)
//                        
//                        Spacer()
//                        
//                        Circle()
//                            .fill(isBlocked ? Color.green : Color.red)
//                            .frame(width: 10, height: 10)
//                            .scaleEffect(isCommandInProgress ? 1.2 : 1.0)
//                            .animation(.easeInOut(duration: 0.5).repeatForever(),
//                                       value: isCommandInProgress)
//                    }
//                    .padding()
//                    .background(
//                        Capsule()
//                            .fill(isBlocked ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
//                    )
//                }
//                .tint(isBlocked ? .green : .red)
//                .disabled(isCommandInProgress)
//                
//                Text(isBlocked ?
//                     "Нажмите, чтобы разрешить использование приложений" :
//                        "Нажмите, чтобы заблокировать все приложения")
//                .font(.caption)
//                .foregroundColor(.secondary)
//                .padding(.horizontal)
//            }
//            
//            Section(header: Text("Отчеты и Настройки")) {
//                NavigationLink(destination: ChildActivityReportView(childName: child.name)) {
//                    HStack(spacing: 15) {
//                        Image(systemName: "chart.bar.xaxis")
//                            .font(.title2)
//                            .foregroundColor(.blue)
//                        Text("Статистика использования")
//                    }
//                }
//                
//                NavigationLink(destination: NotificationReportView(childName: child.name)) {
//                    HStack(spacing: 15) {
//                        Image(systemName: "chart.bar.xaxis")
//                            .font(.title2)
//                            .foregroundColor(.orange)
//                        Text("Статистика уведомлений")
//                    }
//                }
//                
//                NavigationLink(destination: PickupsReportView(childName: child.name)) {
//                    HStack(spacing: 15) {
//                        Image(systemName: "chart.bar.xaxis")
//                            .font(.title2)
//                            .foregroundColor(.purple)
//                        Text("Статистика поднятий")
//                    }
//                }
//            }
//            
////            NavigationLink(destination: ChildLocationView(child: child)) {
////                HStack {
////                    Image(systemName: "location.fill")
////                        .foregroundColor(.blue)
////                    
////                    VStack(alignment: .leading) {
////                        Text(child.name)
////                            .font(.headline)
////                        
////                        // Можно добавить последнее известное местоположение
////                        Text("Последнее обновление: 10 мин назад")
////                            .font(.caption)
////                            .foregroundColor(.secondary)
////                    }
////                }
////            }
//        }
//        .navigationTitle(child.name)
////        .overlay {
////            if showingBlockProgress || showingUnblockProgress {
////                CommandExecutionOverlay(
////                    isShowing: showingBlockProgress ? $showingBlockProgress : $showingUnblockProgress,
////                    commandType: showingBlockProgress ? "block_all_apps" : "unblock_all_apps",
////                    childID: child.recordID
////                )
////            }
////        }
//        .onReceive(cloudKitManager.$pendingCommands) { _ in
//            checkCommandCompletion()
//        }
//    }
//    
//    private func toggleBlock() {
//        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
//            
//            if isBlocked {
//                authManager.sendUnblockCommand(for: child.recordID)
//            } else {
//                authManager.sendBlockCommand(for: child.recordID)
//            }
//            
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                withAnimation {
//                    isBlocked.toggle()
//                }
//            }
//        }
//    }
//    
//    private func checkCommandCompletion() {
//        let activeCommands = getActiveCommandsForChild()
//        
//        if activeCommands.isEmpty {
//            showingBlockProgress = false
//            showingUnblockProgress = false
//        }
//    }
//    
//    private var isCommandInProgress: Bool {
//        !getActiveCommandsForChild().isEmpty
//    }
//    
//    private var activeCommands: [CommandStatus] {
//        getActiveCommandsForChild()
//    }
//    
//    private func getActiveCommandsForChild() -> [CommandStatus] {
////        authManager.getActiveCommands(for: child.recordID)
//    }
//}
