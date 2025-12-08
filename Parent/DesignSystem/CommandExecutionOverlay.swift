////
////  CommandExecutionOverlay.swift
////  Parent
////
////  Created by Михаил Шаговитов on 26.11.2025.
////
//
//import SwiftUI
//
//struct CommandExecutionOverlay: View {
//    @Binding var isShowing: Bool
//    let commandType: String
//    let childID: String
//    
//    @State private var cloudKitManager = CloudKitManager.shared
//    @State private var progress: Double = 0.0
//    @State private var statusText: String = "Отправка команды..."
//    
//    var body: some View {
//        ZStack {
//            Color.black.opacity(0.4)
//                .ignoresSafeArea()
//            
//            VStack(spacing: 20) {
//                ProgressView(value: progress)
//                    .progressViewStyle(LinearProgressViewStyle())
//                
//                Text(statusText)
//                    .foregroundColor(.black)
//                    .multilineTextAlignment(.center)
//            }
//            .padding()
//            .background(Color(.systemGray6))
//            .cornerRadius(12)
//            .shadow(radius: 10)
//            .padding(.horizontal, 40)
//        }
//        .onAppear {
//            startProgressAnimation()
//            monitorCommandProgress()
//        }
//    }
//    
//    private func startProgressAnimation() {
//        withAnimation(.easeInOut(duration: 30)) {
//            progress = 0.9
//        }
//    }
//    
//    private func monitorCommandProgress() {
//        Task {
//            var attempts = 0
//            while attempts < 30 && isShowing {
//                try? await Task.sleep(nanoseconds: 2_000_000_000)
//                
//                let activeCommands = CloudKitManager.shared.pendingCommands.values.filter {
//                    $0.targetChildID == childID
//                }
//                
//                if activeCommands.isEmpty {
//                    await MainActor.run {
//                        withAnimation {
//                            progress = 1.0
//                            statusText = "Команда выполнена!"
//                        }
//                        
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                            isShowing = false
//                        }
//                    }
//                    break
//                } else {
//                    await MainActor.run {
//                        if let command = activeCommands.first {
//                            statusText = statusDescription(command.status)
//                        }
//                    }
//                }
//                
//                attempts += 1
//            }
//            
//            if isShowing {
//                await MainActor.run {
//                    statusText = "Таймаут выполнения команды"
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                        isShowing = false
//                    }
//                }
//            }
//        }
//    }
//    
//    private func statusDescription(_ status: CommandStatus.Status) -> String {
//        switch status {
//        case .pending: return "Отправка команды..."
//        case .delivered: return "Команда доставлена на устройство"
//        case .executed: return "Команда выполняется..."
//        case .failed: return "Ошибка выполнения"
//        case .executing:
//            return "Ошибка"
//        case .timeout:
//            return "Время вышло"
//        case .notFound:
//            return "Не найдено"
//        }
//    }
//}
//
//
//#Preview {
//    CommandExecutionOverlay_PreviewWrapper()
//}
//
//struct CommandExecutionOverlay_PreviewWrapper: View {
//    @State private var isShowing = true
//    
//    var body: some View {
//        CommandExecutionOverlay(
//            isShowing: $isShowing,
//            commandType: "block_all_apps",
//            childID: "child_12345"
//        )
//    }
//}
