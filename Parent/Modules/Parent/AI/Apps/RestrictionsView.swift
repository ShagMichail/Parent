//
//  RestrictionsView.swift
//  Parent
//
//  Created by Michail Shagovitov on 18.12.2025.
//

//struct PendingRestriction: Codable, Identifiable {
//    let id = UUID()
//    var action: ActionType
//    var token: ApplicationToken
//    var appName: String // Сохраняем имя для удобного отображения
//    
//    enum ActionType: String, Codable {
//        case block = "Заблокировать"
//        case unblock = "Разблокировать"
//        case setLimit = "Установить лимит"
//    }
//}
//
//// RestrictionsView.swift (в ОСНОВНОМ приложении)
//import SwiftUI
//import FamilyControls
//import ManagedSettings
//
//struct RestrictionsView: View {
//    @EnvironmentObject var cloudKitManager: CloudKitManager
//    @EnvironmentObject var stateManager: AppStateManager // Нужен для ID ребенка
//    
//    @State private var pendingRestrictions: [PendingRestriction] = []
//    
//    var body: some View {
//        NavigationView {
//            List {
//                if pendingRestrictions.isEmpty {
//                    Text("Нет запланированных ограничений.")
//                } else {
//                    ForEach(pendingRestrictions) { restriction in
//                        VStack(alignment: .leading) {
//                            Text("\(restriction.appName)")
//                                .font(.headline)
//                            
//                            HStack {
//                                Label(restriction.token).labelStyle(.iconOnly)
//                                Button("Применить") {
//                                    apply(restriction)
//                                }
//                                .buttonStyle(.borderedProminent)
//                            }
//                        }
//                    }
//                    .onDelete(perform: deleteRestriction)
//                }
//            }
//            .navigationTitle("Запланированные действия")
//            .onAppear(perform: loadPendingRestrictions)
//        }
//    }
//    
//    private func loadPendingRestrictions() {
//        guard let defaults = UserDefaults(suiteName: "group.com.laborato.test.Parent") else { return }
//        if let data = defaults.data(forKey: "pendingRestrictions") {
//            self.pendingRestrictions = (try? JSONDecoder().decode([PendingRestriction].self, from: data)) ?? []
//        }
//    }
//    
//    private func saveRestrictions() {
//        guard let defaults = UserDefaults(suiteName: "group.com.laborato.test.Parent") else { return }
//        if let data = try? JSONEncoder().encode(pendingRestrictions) {
//            defaults.set(data, forKey: "pendingRestrictions")
//        }
//    }
//    
//    private func deleteRestriction(at offsets: IndexSet) {
//        pendingRestrictions.remove(atOffsets: offsets)
//        saveRestrictions()
//    }
//    
//    private func apply(_ restriction: PendingRestriction) {
//        guard let childID = stateManager.children.first?.recordID else { return } // Берем первого ребенка для примера
//        
//        let commandName = (restriction.action == .block) ? "block_app_token" : "unblock_app_token"
////        let payload: [String: Any] = ["token": restriction.token]
//        
//        Task {
//            do {
////                try await cloudKitManager.sendCommand(name: commandName, to: childID, payload: payload)
//                try await cloudKitManager.sendCommand(name: commandName, to: childID)
//                // Если успешно, удаляем задачу из списка
//                pendingRestrictions.removeAll { $0.id == restriction.id }
//                saveRestrictions()
//            } catch {
//                print("❌ Ошибка применения ограничения: \(error)")
//            }
//        }
//    }
//}
