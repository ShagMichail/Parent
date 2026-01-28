//
//  ChildOnboardingView.swift
//  Parent
//
//  Created by Michail Shagovitov on 13.01.2026.
//

import SwiftUI
import UserNotifications
import CoreLocation

struct ChildOnboardingView: View {
    @EnvironmentObject var locationManager: LocationManager
    @Binding var isPresented: Bool
    @AppStorage("hasCompletedChildOnboarding") private var hasCompleted = false
    
    @State private var currentPage = 0
    @State private var isRequestingPermission = false
    
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    enum PermissionType {
        case notifications
        case location
    }
    
    var body: some View {
        VStack {
            ZStack {
                if currentPage == 0 {
                    OnboardingPageView(
                        imageName: "child-notifications",
                        title: String(localized: "Stay in touch"),
                        description: String(localized: "Allow notifications so your device can immediately receive commands from your parents"),
                        isRequesting: $isRequestingPermission
                    ) {
                        requestNotifications()
                    }
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                    .zIndex(currentPage == 0 ? 1 : 0)
                }
                
                if currentPage == 1 {
                    OnboardingPageView(
                        imageName: "child-location",
                        title: String(localized: "Safety first"),
                        description: String(localized: "Allow location access so your parents always know you're safe"),
                        isRequesting: $isRequestingPermission
                    ) {
                        requestLocation()
                    }
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                    .zIndex(currentPage == 1 ? 1 : 0)
                }
                if currentPage == 2 {
                    VStack {
                        Image("child-keyboard")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 250, height: 250)
                            .padding(.bottom, 40)
                        
                        Text("Use the keyboard from Parent")
                            .font(.custom("Inter-SemiBold", size: 24))
                            .foregroundColor(.blackText)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 25)
                        
                        // --- Подробная инструкция ---
                        VStack(alignment: .leading, spacing: 20) {
                            InstructionRow(
                                model: InstructionRowModel(
                                    number: "1",
                                    text: String(localized: "Open the 'Settings' of the child's iPhone")
                                )
                            )
                            
                            InstructionRow(
                                model: InstructionRowModel(
                                    number: "2",
                                    text: String(localized: "Go to 'Basic' -> 'Keyboard' -> 'Keyboards'")
                                )
                            )
                            
                            InstructionRow(
                                model: InstructionRowModel(
                                    number: "3",
                                    text: String(localized: "Click on 'New Keyboards' and select 'Parental Control' (the name of your keyboard)")
                                )
                            )
                            
                            InstructionRow(
                                model: InstructionRowModel(
                                    number: "4",
                                    text: String(localized: "Click on the added keyboard and enable 'Allow Full Access'")
                                )
                            )
                        }
                        .padding(.bottom, 25)
                        
                        Text("This is necessary to analyze the input text")
                            .font(.custom("Inter-Regular", size: 12))
                            .foregroundColor(.strokeTextField)
                            .multilineTextAlignment(.center)
                        
                        Spacer()
                        
                        ContinueButton(
                            model: ContinueButtonModel(
                                title: String(localized: "Continue"),
                                isEnabled: true,
                                fullWidth: true,
                                action: {
                                    completeOnboarding()
                                }
                            )
                        )
                        .frame(height: 50)
                    }
                    .padding(.horizontal, 20)
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                    .zIndex(currentPage == 2 ? 1 : 0)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: currentPage)
        }
        .background(Color.roleBackground.ignoresSafeArea())
        .onChange(of: locationManager.authorizationStatus) { _, newStatus in
            if currentPage == 1 && newStatus != .notDetermined {
                isRequestingPermission = false
                if newStatus == .authorizedAlways || newStatus == .authorizedWhenInUse {
                    withAnimation {
                        currentPage = 2
                    }
                } else {
                    showPermissionDeniedAlert(for: .location)
                }
            }
        }
        .alert(alertTitle, isPresented: $showAlert) {
            Button("Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }
    
    // MARK: - Логика разрешений
    
    private func requestNotifications() {
        guard !isRequestingPermission else { return }
        isRequestingPermission = true
        
        Task {
            let center = UNUserNotificationCenter.current()
            do {
                let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
                
                await MainActor.run {
                    isRequestingPermission = false
                    
                    if granted {
                        UIApplication.shared.registerForRemoteNotifications()
                        withAnimation {
                            currentPage = 1
                        }
                    } else {
                        showPermissionDeniedAlert(for: .notifications)
                        print("❌ Пользователь отказал в доступе к уведомлениям.")
                    }
                }
            } catch {
                print("🚨 Ошибка запроса уведомлений: \(error)")
                await MainActor.run { isRequestingPermission = false }
            }
        }
    }
    
    private func showPermissionDeniedAlert(for permission: PermissionType) {
        if permission == .notifications {
            alertTitle = String(localized: "Notifications are disabled")
            alertMessage = String(localized: "To receive commands from parents, please allow notifications in the Settings.")
        } else {
            alertTitle = String(localized: "Geolocation is disabled")
            alertMessage = String(localized: "So that parents can see where you are, please allow access to geolocation in the Settings.")
        }
        
        showAlert = true
    }
    
    private func requestLocation() {
        guard !isRequestingPermission else { return }
        
        let currentStatus = locationManager.authorizationStatus
        
        if currentStatus == .authorizedAlways || currentStatus == .authorizedWhenInUse {
            print("✅ Доступ к геолокации уже был предоставлен. Завершаем онбординг.")
            completeOnboarding()
            return
        }
        
        if currentStatus == .denied || currentStatus == .restricted {
            print("❌ Доступ к геолокаци уже был запрещен. Показываем алерт.")
            showPermissionDeniedAlert(for: .location)
            return
        }
        
        isRequestingPermission = true
        
        locationManager.requestPermission()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
            if isRequestingPermission {
                isRequestingPermission = false
            }
        }
    }
    
    private func completeOnboarding() {
        hasCompleted = true
        locationManager.startTracking()
        isPresented = false
    }
}

#Preview {
    ChildOnboardingView(isPresented: .constant(true))
        .environmentObject(LocationManager.shared)
}
