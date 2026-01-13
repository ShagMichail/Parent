//
//  ChildDashboardView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 11.11.2025.
//

//import SwiftUI
//
//struct ChildDashboardView: View {
//    @EnvironmentObject var locationManager: LocationManager
//    @EnvironmentObject var stateManager: AppStateManager
//    
//    @State private var childName: String = "пользователь"
//    
//    private let childNameStorageKey = "com.laborato.child.name"
//    
//    var body: some View {
//        VStack(alignment: .center) {
//            Spacer()
//            VStack(spacing: 15) {
//                HStack(spacing: 4) {
//                    Text("Hello,")
//                    Text("\(childName)!")
//                }
//                .font(.custom("Inter-SemiBold", size: 26))
//                .foregroundColor(.accent)
//                
//                Text("Your phone is connected to your family")
//                    .font(.custom("Inter-Medium", size: 18))
//                    .foregroundColor(.accent)
//                
//            }
//            Spacer()
//            Image("child_home")
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//            
//            Spacer()
//        }
//        
//        .onAppear {
//            loadChildName()
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                if locationManager.authorizationStatus == .notDetermined {
//                    locationManager.requestPermission()
//                }
//                locationManager.startTracking()
//            }
//            // убрать в дальнейшем
//            stateManager.didCompletePairing()
//        }
//    }
//    
//    private func loadChildName() {
//        if let savedName = UserDefaults.standard.string(forKey: childNameStorageKey) {
//            self.childName = savedName
//            print("👤 Имя ребенка '\(savedName)' успешно загружено.")
//        } else {
//            print("⚠️ Имя ребенка не найдено в UserDefaults.")
//        }
//    }
//}


import SwiftUI

struct ChildDashboardView: View {
    @EnvironmentObject var locationManager: LocationManager
    
    @StateObject private var viewModel = ChildDashboardViewModel()
    @AppStorage("hasCompletedChildOnboarding") private var hasCompletedOnboarding = false
    @State private var showOnboarding = false
    
    var body: some View {
        NavigationView {
            VStack {
                Image("child_home")
                    .resizable()
                    .frame(width: 120, height: 120)
                    .aspectRatio(contentMode: .fit)
                VStack(spacing: 15) {
                    HStack(spacing: 4) {
                        Text("Hello,")
                        Text("\(viewModel.childName)!")
                    }
                    .font(.custom("Inter-SemiBold", size: 26))
                    .foregroundColor(.accent)
                    
                    Text("Your phone is connected to your family")
                        .font(.custom("Inter-Medium", size: 18))
                        .foregroundColor(.accent)
                }

                // --- Список ограничений ---
                if viewModel.isLoading {
                    Spacer()
                    ProgressView(String(localized: "Uploading rules..."))
                        .frame(maxWidth: .infinity)
                    Spacer()
                } else {
                    ScrollView {
                        if viewModel.restrictions.isEmpty {
                            RestrictionRowView(
                                item: RestrictionItem(
                                    id: UUID().uuidString,
                                    title: String(localized: "There are no restrictions"),
                                    description: String(localized: "The parent did not set any restrictions"),
                                    iconName: "unlock-command"
                                )
                            )
                            .padding(.horizontal, 10)
                            .padding(.vertical, 10)
                            
                        } else {
                            VStack {
                                ForEach(viewModel.restrictions) { item in
                                    RestrictionRowView(item: item)
                                }
                                .padding(.horizontal, 10)
                            }
                            .padding(.vertical, 10)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
//            .onAppear {
//                Task {
//                    await viewModel.fetchAllRestrictions()
//                }
//                
//                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                    if locationManager.authorizationStatus == .notDetermined {
//                        locationManager.requestPermission()
//                    }
//                    locationManager.startTracking()
//                }
//            }
            
            .onAppear {
                // Если онбординг не пройден, показываем его
                if !hasCompletedOnboarding {
                    showOnboarding = true
                } else {
                    // Если уже пройден, просто грузим данные и запускаем локацию
                    Task { await viewModel.fetchAllRestrictions() }
                    locationManager.startTracking()
                }
            }
            // ✅ 3. Модальное окно на весь экран с онбордингом
            .fullScreenCover(isPresented: $showOnboarding, onDismiss: {
                // Вызывается, когда онбординг закрыт
                Task { await viewModel.fetchAllRestrictions() }
            }) {
                ChildOnboardingView(isPresented: $showOnboarding)
                    .environmentObject(locationManager)
            }
            
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            await viewModel.fetchAllRestrictions()
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .refreshable {
                Task {
                    await viewModel.fetchAllRestrictions()
                }
            }
            .background(Color.white.ignoresSafeArea())
        }
    }
}
