//
//  ParentDashboardView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 10.11.2025.
//

import SwiftUI
import FamilyControls
import DeviceActivity

struct ParentDashboardView: View {
    @EnvironmentObject var stateManager: AuthenticationManager
    @State private var isAddingChild = false
    
    var body: some View {
        NavigationView {
            VStack {
                if stateManager.children.isEmpty {
                    EmptyStateView(isAddingChild: $isAddingChild)
                } else {
                    ChildrenListView()
                }
            }
            .navigationTitle("Мои дети")
            .toolbar {
                if !stateManager.children.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            isAddingChild = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $isAddingChild) {
                AddChildView { name, recordID in
                    stateManager.addChild(name: name, recordID: recordID)
                }
            }
        }
    }
}

struct SelectAppsButton: View {
    @EnvironmentObject var familyManager: FamilyManager
    @State private var isPickerPresented = false
    @State private var selection = FamilyActivitySelection()
    
    var body: some View {
        Button {
            isPickerPresented = true
        } label: {
            HStack {
                Image(systemName: "app.badge.xmark.fill")
                    .font(.title2)
                VStack(alignment: .leading) {
                    Text("Блокировка приложений")
                        .font(.headline)
                    Text("Выберите приложения для ограничения")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.orange.opacity(0.1))
            .cornerRadius(12)
        }
        .familyActivityPicker(isPresented: $isPickerPresented, selection: $selection)
        .onChange(of: selection) { oldSelection, newSelection in
            familyManager.setBlockedItems(from: newSelection)
        }
    }
}

// Расширение для получения реальных данных DeviceActivity
extension DeviceActivityReport {
    static func generateDailyReport() async -> [AppUsage] {
        // Здесь будет код для получения реальных данных
        // из DeviceActivityMonitor
        
        // Заглушка с тестовыми данными
        return [
            AppUsage(appName: "TikTok", duration: 5400), // 1.5 часа
            AppUsage(appName: "YouTube", duration: 2700), // 45 минут
            AppUsage(appName: "Minecraft", duration: 3600), // 1 час
            AppUsage(appName: "Duolingo", duration: 1800), // 30 минут
            AppUsage(appName: "Safari", duration: 900) // 15 минут
        ]
    }
}

struct AppUsage {
    let appName: String
    let duration: TimeInterval // в секундах
}

// Вспомогательный View для состояния, когда детей нет
struct EmptyStateView: View {
    @Binding var isAddingChild: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "person.3.fill")
                .font(.system(size: 80))
                .foregroundColor(.gray)
            Text("Дети еще не добавлены")
                .font(.title2)
                .fontWeight(.bold)
            Text("Нажмите кнопку ниже, чтобы добавить первое устройство ребенка.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Button("Добавить ребенка") {
                isAddingChild = true
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.top)
            Spacer()
            Spacer()
        }
        .padding()
    }
}

// Вспомогательный View для отображения списка детей
struct ChildrenListView: View {
    @EnvironmentObject var stateManager: AuthenticationManager

    var body: some View {
        List {
            ForEach(stateManager.children) { child in
                // NavigationLink автоматически создаст стрелочку и переход
                NavigationLink(destination: ChildDetailView(child: child)) {
                    HStack {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.blue)
                        Text(child.name)
                            .font(.headline)
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .listStyle(.insetGrouped) // Используем красивый стиль списка
    }
}
