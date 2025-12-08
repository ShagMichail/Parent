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
//    @EnvironmentObject var stateManager: AppStateManager
    @EnvironmentObject var cloudKitManager: CloudKitManager
    @StateObject private var viewModel: ParentDashboardViewModel
    @State private var isAddingChild = false
    @State private var showDivider = false
    
    init(stateManager: AppStateManager) {
        // Мы не можем получить доступ к authManager напрямую в `init`,
        // поэтому используем временное решение.
        // В более крупных проектах это делается через DI-контейнер.
        // В данном случае, так как authManager синглтон, это безопасно.
        _viewModel = StateObject(wrappedValue:
                                    ParentDashboardViewModel(
                                        stateManager: stateManager,
                                        cloudKitManager: CloudKitManager.shared
                                    ))
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                NavigationBar(
                    model: NavigationBarModel(
                        mainTitle: "Дети",
                        hasNotification: true,
                        hasNewNotification: true,
                        onBackTap: {},
                        onNotificationTap: {}
                    )
                )
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        // Верхняя панель переключения детей
                        ChildSelectorView(
                            children: $viewModel.children,
                            selectedChild: $viewModel.selectedChild,
                            onAddChild: {
                                isAddingChild = true
                            }
                        )
                        .padding(.bottom, 10)
                        
                        // Основной контент для выбранного ребенка
                        if let selectedChild = viewModel.selectedChild {
                            ChildDashboardDetailView(viewModel: viewModel)
                            // Добавляем transition для плавной смены
                                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                        } else {
                            // Показываем, если детей нет
                            ContentUnavailableView("Добавьте ребенка", systemImage: "person.3.fill", description: Text("Нажмите на '+' чтобы добавить первого ребенка."))
                        }
                    }
                    .padding(.bottom, 20)
                }
                .background(Color.roleBackround.ignoresSafeArea())
                .sheet(isPresented: $isAddingChild) {
                    // Здесь ваш экран добавления ребенка
                    AddChildView()
                }
            }
        }
        .id(viewModel.selectedChild?.id) // Ключевой трюк для обновления
    }
}
