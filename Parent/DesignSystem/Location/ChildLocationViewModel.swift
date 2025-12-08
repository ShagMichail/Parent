////
////  ChildLocationViewModel.swift
////  Parent
////
////  Created by Михаил Шаговитов on 02.12.2025.
////
//
//import SwiftUI
//
//class ChildLocationViewModel: ObservableObject {
//    @Published var locations: [ChildLocation] = []
//    @Published var isOnline = false
//    @Published var lastUpdateTime: Date?
//    @Published var isLoading = false
//    
//    private let childID: String
//    private let cloudKitManager = CloudKitManager.shared
//    
//    init(childID: String) {
//        self.childID = childID
//        print("📍 ViewModel создана для childID: '\(childID)'")
//        loadLocationData()
//    }
//    
//    func loadLocationData(hours: Int = 24) {
//        guard !isLoading else { return }
//        
//        isLoading = true
//        print("🔄 Загрузка данных для childID: '\(childID)'")
//        
//        Task {
//            do {
//                let locations = try await cloudKitManager.fetchLocationHistory(
//                    for: childID,
//                    hours: hours
//                )
//                
//                await MainActor.run {
//                    self.locations = locations
//                    self.isLoading = false
//                    self.checkOnlineStatus()
//                    print("✅ Загружено \(locations.count) локаций")
//                    
//                    // Логирование для отладки
//                    if locations.isEmpty {
//                        print("⚠️ Локаций не найдено, проверьте:")
//                        print("   - childID в базе: '\(self.childID)'")
//                        print("   - CloudKit Dashboard")
//                    }
//                }
//            } catch {
//                await MainActor.run {
//                    self.isLoading = false
//                    print("❌ Ошибка загрузки: \(error)")
//                }
//            }
//        }
//    }
//    
//    private func checkOnlineStatus() {
//        guard let lastUpdate = locations.first?.timestamp else {
//            isOnline = false
//            return
//        }
//        
//        let fifteenMinutesAgo = Date().addingTimeInterval(-900)
//        isOnline = lastUpdate > fifteenMinutesAgo
//        lastUpdateTime = lastUpdate
//        
//        print("📡 Статус онлайн: \(isOnline ? "Да" : "Нет")")
//        print("   Последнее обновление: \(lastUpdate)")
//    }
//}
//
