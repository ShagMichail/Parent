//
//  CommandProgressView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 26.11.2025.
//

import SwiftUI

//struct CommandProgressView: View {
//    let commands: [CommandStatus]
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            Text("Выполняемые команды:")
//                .font(.headline)
//            
//            ForEach(commands, id: \.recordID) { command in
//                HStack {
//                    VStack(alignment: .leading) {
//                        Text(command.commandName == "block_all_apps" ? "Блокировка" : "Разблокировка")
//                            .font(.subheadline)
//                        
//                        Text(statusDescription(command.status))
//                            .font(.caption)
//                            .foregroundColor(statusColor(command.status))
//                    }
//                    
//                    Spacer()
//                    
//                    ProgressView()
//                        .scaleEffect(0.8)
//                }
//                .padding(.vertical, 4)
//            }
//        }
//        .padding()
//        .background(Color.gray.opacity(0.1))
//        .cornerRadius(8)
//    }
//    
////    private func statusDescription(_ status: CommandStatus.Status) -> String {
////        switch status {
////        case .pending: return "Отправляется..."
////        case .delivered: return "Доставлено на устройство"
////        case .executed: return "Выполнено"
////        case .failed: return "Ошибка выполнения"
////        case .executing:
////            return "Ошибка"
////        case .timeout:
////            return "Ошибка"
////        case .notFound:
////            return "Ошибка"
////        }
////    }
//    
////    private func statusColor(_ status: CommandStatus.Status) -> Color {
////        switch status {
////        case .pending: return .orange
////        case .delivered: return .blue
////        case .executed: return .green
////        case .failed: return .red
////        case .executing:
////            return .red
////        case .timeout:
////            return .red
////        case .notFound:
////            return .red
////        }
////    }
//}
