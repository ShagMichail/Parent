////
////  QuickChildActionsView.swift
////  Parent
////
////  Created by Михаил Шаговитов on 10.11.2025.
////
//
//import FamilyControls
//import SwiftUI
//
//struct QuickChildActionsView: View {
//    let child: Child
//    @Binding var showingRestrictions: Bool
//    @Binding var showingTimeLimit: Bool
//    @EnvironmentObject var parentManager: ParentControlManager
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            Text("Быстрые действия")
//                .font(.headline)
//            
//            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
//                QuickActionButton(
//                    title: "Ограничения",
//                    icon: "app.badge.xmark",
//                    color: .red
//                ) {
//                    showingRestrictions = true
//                }
//                
//                QuickActionButton(
//                    title: "Лимит времени",
//                    icon: "timer",
//                    color: .blue
//                ) {
//                    showingTimeLimit = true
//                }
//                
//                QuickActionButton(
//                    title: "Заблокировать игры",
//                    icon: "gamecontroller",
//                    color: .purple
//                ) {
//                    blockGames()
//                }
//                
//                QuickActionButton(
//                    title: "Заблокировать соцсети",
//                    icon: "message",
//                    color: .orange
//                ) {
//                    blockSocialNetworks()
//                }
//                
//                QuickActionButton(
//                    title: "Разрешить всё",
//                    icon: "lock.open",
//                    color: .green
//                ) {
//                    removeAllRestrictions()
//                }
//                
//                QuickActionButton(
//                    title: "Экстренная блокировка",
//                    icon: "exclamationmark.triangle",
//                    color: .red
//                ) {
//                    emergencyBlock()
//                }
//            }
//        }
//        .padding()
//        .background(Color(.systemBackground))
//        .cornerRadius(12)
//        .shadow(color: .gray.opacity(0.2), radius: 5)
//    }
//    
//    private func blockGames() {
//        var selection = child.restrictions
//        // Здесь будет логика блокировки категории игр
//        // В реальном приложении нужно использовать реальные категории
//        parentManager.updateRestrictions(for: child, selection: selection)
//    }
//    
//    private func blockSocialNetworks() {
//        var selection = child.restrictions
//        // Логика блокировки социальных сетей
//        parentManager.updateRestrictions(for: child, selection: selection)
//    }
//    
//    private func removeAllRestrictions() {
//        let emptySelection = FamilyActivitySelection()
//        parentManager.updateRestrictions(for: child, selection: emptySelection)
//    }
//    
//    private func emergencyBlock() {
//        var selection = FamilyActivitySelection()
//        // Блокировка всех приложений кроме звонков
//        parentManager.updateRestrictions(for: child, selection: selection)
//    }
//}
