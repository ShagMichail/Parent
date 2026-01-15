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
    
    
    var body: some View {
        VStack {
            if currentPage == 0 {
                OnboardingPageView(
                    imageName: "child-notifications",
                    title: String(localized: "Stay in touch"),
                    description: String(localized: "Allow notifications so your device can immediately receive commands from your parents."),
                    isRequesting: $isRequestingPermission
                ) {
                    requestNotifications()
                }
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            }
            
            if currentPage == 1 {
                OnboardingPageView(
                    imageName: "child-location",
                    title: String(localized: "Safety first"),
                    description: String(localized: "Allow location access so your parents always know you're safe."),
                    isRequesting: $isRequestingPermission
                ) {
                    requestLocation()
                }
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            }
            if currentPage == 2 {
                // --- ✅ ОБНОВЛЕННАЯ СТРАНИЦА 3: КЛАВИАТУРА ---
                // Используем ScrollView, так как инструкция может быть длинной
                ScrollView {
                    VStack(spacing: 30) {
                        Image(systemName: "keyboard.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.accentColor)
                        
                        Text("Включите клавиатуру")
                            .font(.custom("Inter-SemiBold", size: 28))
                        
                        // --- Подробная инструкция ---
                        VStack(alignment: .leading, spacing: 20) {
                            InstructionStepView(number: "1", text: "Откройте **Настройки** вашего iPhone.")
                            InstructionStepView(number: "2", text: "Перейдите в **Основные** > **Клавиатура** > **Клавиатуры**.")
                            InstructionStepView(number: "3", text: "Нажмите **Новые клавиатуры...** и выберите **'Parental Control'** (название вашей клавиатуры).")
                            InstructionStepView(number: "4", text: "Нажмите на добавленную клавиатуру и **включите 'Разрешить полный доступ'**.")
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        
                        Text("Это необходимо для анализа вводимого текста.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        // Кнопка "Я все сделал(а)!"
                        Button(action: {
                            // Просто завершаем онбординг
                            completeOnboarding()
                        }) {
                            Text("Готово")
                                .font(.custom("Inter-Medium", size: 18))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 15).fill(Color.accentColor))
                        }
                    }
                    .padding()
                }
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            }
        }
        .background(Color.roleBackground.ignoresSafeArea())
        //        .onChange(of: locationManager.authorizationStatus) { _, newStatus in
        //            if currentPage == 1 && newStatus != .notDetermined {
        //                isRequestingPermission = false
        //
        //                if newStatus == .authorizedAlways || newStatus == .authorizedWhenInUse {
        //                    completeOnboarding()
        //                } else {
        //                    print("❌ Пользователь отказал в доступе к геолокации.")
        //                }
        //            }
        //        }
        .onChange(of: locationManager.authorizationStatus) { _, newStatus in
            if currentPage == 1 && newStatus != .notDetermined {
                isRequestingPermission = false
                if newStatus == .authorizedAlways || newStatus == .authorizedWhenInUse {
                    // ✅ ПЕРЕХОД НА СЛЕДУЮЩИЙ ШАГ
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
    
    enum PermissionType {
        case notifications
        case location
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

struct InstructionStepView: View {
    let number: String
    let text: LocalizedStringKey // Используем LocalizedStringKey для поддержки Markdown
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Text(number)
                .font(.headline.bold())
                .foregroundColor(.white)
                .frame(width: 30, height: 30)
                .background(Circle().fill(Color.accentColor))
            
            Text(text)
                .font(.body)
        }
    }
}
