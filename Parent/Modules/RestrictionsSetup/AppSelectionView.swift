//
//  AppSelectionView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 11.11.2025.
//

//import FamilyControls
//import SwiftUI
//
//struct AppSelectionView: View {
//    @Binding var selection: FamilyActivitySelection
//    @State private var isAuthorized = false
//    @State private var isLoading = true
//    
//    var body: some View {
//        Group {
//            if isLoading {
//                ProgressView("Загрузка приложений...")
//            } else if isAuthorized {
//                FamilyActivityPicker(selection: $selection)
//                    .onChange(of: selection) { newValue in
//                        print("Выбрано приложений: \(newValue.applicationTokens.count)")
//                    }
//            } else {
//                AuthorizationRequiredView()
//            }
//        }
//        .onAppear {
//            checkAuthorization()
//        }
//        .navigationTitle("Выбор приложений")
//        .navigationBarTitleDisplayMode(.inline)
//    }
//    
//    private func checkAuthorization() {
//        let center = AuthorizationCenter.shared
//        switch center.authorizationStatus {
//        case .approved:
//            isAuthorized = true
//            isLoading = false
//        case .denied:
//            isAuthorized = false
//            isLoading = false
//        case .notDetermined:
//            requestAuthorization()
//        @unknown default:
//            isLoading = false
//        }
//    }
//    
//    private func requestAuthorization() {
//        Task {
//            do {
//                try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
//                await MainActor.run {
//                    isAuthorized = true
//                    isLoading = false
//                }
//            } catch {
//                await MainActor.run {
//                    isAuthorized = false
//                    isLoading = false
//                }
//            }
//        }
//    }
//}
