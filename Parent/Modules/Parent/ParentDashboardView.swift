//
//  ParentDashboardView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 10.11.2025.
//

import SwiftUI

struct ParentDashboardView: View {
    @EnvironmentObject var familyManager: FamilyManager
    @State private var familyStatus: FamilyStatus = .unknown
    @State private var isLoading = true
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView("Проверка статуса семьи...")
            } else {
                switch familyStatus {
                case .setupWithChildren:
                    ParentMainView() // Основной экран с детьми
                    
                case .setupNoChildren:
                    NoChildrenView() // Экран "добавьте детей"
                    
                case .notAuthorized:
                    FamilyAuthorizationView() // Запрос авторизации FamilyControls
                    
                case .denied:
                    AuthorizationDeniedView() // Авторизация отклонена
                    
                case .notParent:
                    Text("Ошибка: не родитель")
                        .onAppear {
                            // Если по какой-то причине сюда попал не родитель
                            familyManager.logout()
                        }
                    
                case .unknown:
                    Text("Неизвестный статус")
                }
            }
        }
        .onAppear {
            checkFamilyStatus()
        }
        .onChange(of: familyManager.familyMembers.count) { oldCount, newCount in
            print("🔄 Количество членов семьи изменилось: \(oldCount) -> \(newCount)")
            checkFamilyStatus()
        }
        .onChange(of: familyManager.authorizationStatus) { oldStatus, newStatus in
            print("🔄 Статус авторизации изменился: \(oldStatus) -> \(newStatus)")
            checkFamilyStatus()
        }
        .navigationTitle("Родительский контроль")
        .navigationBarTitleDisplayMode(.large)
    }
    
    private func checkFamilyStatus() {
        Task {
            let status = await familyManager.checkFamilyStatus()
            await MainActor.run {
                familyStatus = status
                isLoading = false
            }
        }
    }
}
