//
//  RestrictionsSetupView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 11.11.2025.
//

import SwiftUI
import FamilyControls

struct RestrictionsSetupView: View {
    let child: FamilyMember
    @EnvironmentObject var familyManager: FamilyManager
    @Environment(\.dismiss) var dismiss
    
    @State private var restrictions = ParentalRestrictions()
    @State private var selectedApps = FamilyActivitySelection()
    @State private var isApplyingRestrictions = false
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        Form {
            // Базовые ограничения
            Section("Основные ограничения") {
                Toggle("Веб-фильтрация", isOn: $restrictions.webFiltering)
                Toggle("Блокировка явного контента", isOn: $restrictions.denyExplicitContent)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Дневной лимит времени")
                        .font(.headline)
                    
                    Picker("Лимит времени", selection: $restrictions.dailyTimeLimit) {
                        Text("Нет лимита").tag(Optional<TimeInterval>.none)
                        Text("30 минут").tag(Optional(30 * 60))
                        Text("1 час").tag(Optional(60 * 60))
                        Text("2 часа").tag(Optional(2 * 60 * 60))
                        Text("3 часа").tag(Optional(3 * 60 * 60))
                    }
                    .pickerStyle(.segmented)
                }
                .padding(.vertical, 4)
            }
            
            // Блокировка приложений
            Section("Блокировка приложений") {
                NavigationLink {
                    AppSelectionView(selection: $selectedApps)
                } label: {
                    HStack {
                        Text("Выбрать приложения")
                        Spacer()
                        Text("\(selectedApps.applicationTokens.count)")
                            .foregroundColor(.secondary)
                    }
                }
                
                if !selectedApps.applicationTokens.isEmpty {
                    Button("Очистить выбор", role: .destructive) {
                        selectedApps = FamilyActivitySelection()
                    }
                    .foregroundColor(.red)
                }
            }
            
            // Быстрые пресеты
            Section("Быстрые настройки") {
                Button("Учебный режим") {
                    applyStudyPreset()
                }
                
                Button("Игровой режим") {
                    applyGamePreset()
                }
                
                Button("Полная блокировка") {
                    applyFullRestrictionPreset()
                }
            }
            
            // Применение ограничений
            Section {
                Button {
                    applyRestrictions()
                } label: {
                    if isApplyingRestrictions {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Применить ограничения")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(isApplyingRestrictions)
                
                Button("Сбросить все ограничения", role: .destructive) {
                    resetRestrictions()
                }
                .frame(maxWidth: .infinity)
                .foregroundColor(.red)
            }
        }
        .navigationTitle("Ограничения для \(child.name)")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Ошибка", isPresented: $showingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func applyStudyPreset() {
        restrictions.webFiltering = true
        restrictions.denyExplicitContent = true
        restrictions.dailyTimeLimit = 1 * 60 * 60 // 1 час
        // Здесь можно добавить автоматический выбор учебных приложений
    }
    
    private func applyGamePreset() {
        restrictions.webFiltering = false
        restrictions.denyExplicitContent = true
        restrictions.dailyTimeLimit = 2 * 60 * 60 // 2 часа
    }
    
    private func applyFullRestrictionPreset() {
        restrictions.webFiltering = true
        restrictions.denyExplicitContent = true
        restrictions.dailyTimeLimit = 30 * 60 // 30 минут
    }
    
    private func applyRestrictions() {
        isApplyingRestrictions = true
        
        // Обновляем appsToBlock с выбранными приложениями
        restrictions.appsToBlock = selectedApps.applicationTokens
        
        Task {
            do {
                try await familyManager.applyRestrictions(to: child, restrictions: restrictions)
                
                await MainActor.run {
                    isApplyingRestrictions = false
                    dismiss()
                }
                
            } catch {
                await MainActor.run {
                    errorMessage = "Ошибка применения ограничений: \(error.localizedDescription)"
                    showingError = true
                    isApplyingRestrictions = false
                }
            }
        }
    }
    
    private func resetRestrictions() {
        restrictions = ParentalRestrictions()
        selectedApps = FamilyActivitySelection()
        
        Task {
            do {
                // Применяем пустые ограничения для сброса
                try await familyManager.applyRestrictions(to: child, restrictions: ParentalRestrictions())
            } catch {
                await MainActor.run {
                    errorMessage = "Ошибка сброса ограничений: \(error.localizedDescription)"
                    showingError = true
                }
            }
        }
    }
}
