//
//  AppInfoButtonsView.swift
//  Parent
//
//  Created by Michail Shagovitov on 18.12.2025.
//

import SwiftUI
import ManagedSettings

//struct PendingRestriction: Codable, Identifiable {
//    let id = UUID()
//    let action: ActionType
//    let token: ApplicationToken
//    let appName: String // Сохраняем имя для удобного отображения
//    
//    enum ActionType: String, Codable {
//        case block = "Заблокировать"
//        case unblock = "Разблокировать"
//        case setLimit = "Установить лимит"
//    }
//}


struct AppInfoButtonsView: View {
    @ObservedObject var viewModel: AppDetailViewModel
    @State private var showingLimitPicker = false
    
    private var installedDate: String {
        return "Неизвестно"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Ограничения")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundColor(.blackText)
            
            VStack(spacing: 0) {
                Button(action: {
//                    viewModel.toggleBlockViaCloudKit()
//                    addPendingRestriction(action: viewModel.isBlocked ? .unblock : .block)
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.redStat)
                        Text("Блокировать")
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(.redStat)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .font(.headline)
                    .padding(.vertical, 20)
                    .padding(.horizontal, 10)
                }
                Divider()
                    .padding(.horizontal, 10)
                Button(action: {
                    showingLimitPicker = true
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "timer")
                            .foregroundColor(.orangeButton)
                        Text("Добавить лимит")
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(.orangeButton)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .font(.headline)
                    .padding(.vertical, 20)
                    .padding(.horizontal, 10)
                }
            }
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
        }
        .padding(.horizontal, 20)
        .disabled(viewModel.isProcessing)
        // ✅ ИЗМЕНЕНИЕ 4: Добавляем .sheet
        .sheet(isPresented: $showingLimitPicker) {
            LimitPickerView { timeInterval in
                viewModel.setUsageLimit(duration: timeInterval)
            }
        }
    }
    
//    private func addPendingRestriction(action: PendingRestriction.ActionType) {
//        guard let defaults = UserDefaults(suiteName: "group.com.laborato.test.Parent") else { return }
//        
//        // Создаем новую задачу
//        let newRestriction = PendingRestriction(
//            action: action,
//            token: viewModel.detail.token,
//            appName: viewModel.detail.application.localizedDisplayName ?? "Приложение"
//        )
//        
//        // Читаем существующий массив задач
//        var pendingRestrictions: [PendingRestriction] = []
//        if let data = defaults.data(forKey: "pendingRestrictions") {
//            pendingRestrictions = (try? JSONDecoder().decode([PendingRestriction].self, from: data)) ?? []
//        }
//        
//        // Добавляем новую задачу и сохраняем
//        pendingRestrictions.append(newRestriction)
//        if let data = try? JSONEncoder().encode(pendingRestrictions) {
//            defaults.set(data, forKey: "pendingRestrictions")
//            print("✅ Задача '\(action.rawValue) \(newRestriction.appName)' добавлена в очередь.")
//            
//            // Опционально: можно показать пользователю подтверждение, что задача добавлена
//        }
//    }
}
