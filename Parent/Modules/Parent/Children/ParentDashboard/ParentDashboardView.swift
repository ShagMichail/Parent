//
//  ParentDashboardView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 10.11.2025.
//

import SwiftUI
import FamilyControls
import DeviceActivity
import Combine

struct HintAnchorKey: PreferenceKey {
    static var defaultValue: Anchor<CGPoint>? = nil
    static func reduce(value: inout Anchor<CGPoint>?, nextValue: () -> Anchor<CGPoint>?) {
        value = value ?? nextValue()
    }
}

struct ParentDashboardView: View {
    @EnvironmentObject var cloudKitManager: CloudKitManager
    @State private var isAddingChild = false
    @State private var showDivider = false
    @State private var reportRefreshID = UUID()
    @State private var navigateToNotifications = false
    @State private var showHelp = false
    @State private var showHelpHint = false
    @EnvironmentObject var viewModel: ParentDashboardViewModel
    @EnvironmentObject var notificationViewModel: NotificationViewModel
    @Binding var isTabBarVisible: Bool
    @Binding var showBlockOverlay: Bool
    var animation: Namespace.ID
    private let lastHintShowDateKey = "lastHelpHintShowDate"
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack(alignment: .top) {
                    VStack(spacing: 0) {
                        NavigationBar(
                            model: NavigationBarModel(
                                mainTitle: String(localized: "Children"),
                                hasNotification: true,
                                hasNewNotification: notificationViewModel.hasAnyNewNotification,
                                hasQuestions: true,
                                onNotificationTap: {
                                    navigateToNotifications.toggle()
                                    isTabBarVisible.toggle()
                                },
                                onQuestionsTap: {
                                    showHelp.toggle()
                                    isTabBarVisible.toggle()
                                }
                            )
                        )
                        .anchorPreference(
                            key: HintAnchorKey.self,
                            value: .topTrailing
                        ) { anchor in
                            return anchor
                        }
                        ScrollView {
                            VStack(alignment: .leading, spacing: 0) {
                                ChildSelectorView(
                                    children: $viewModel.children,
                                    selectedChild: $viewModel.selectedChild,
                                    showBatteryLevel: true,
                                    canChildAdd: true,
                                    onAddChild: {
                                        isAddingChild = true
                                    }
                                )
                                .padding(.bottom, 10)
                                
                                if viewModel.selectedChild != nil {
                                    ChildDashboardDetailView(
                                        showBlockOverlay: $showBlockOverlay,
                                        isTabBarVisible: $isTabBarVisible,
                                        animation: animation
                                    )
                                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                                    .id(reportRefreshID)
                                    .onAppear {
                                        viewModel.refreshChildStatus()
                                    }
                                    .id(viewModel.selectedChild?.id)
                                } else {
                                    ContentUnavailableView("Add a child", systemImage: "person.3.fill", description: Text("Click on the '+' to add the first child."))
                                }
                            }
                            .padding(.bottom, 80)
                        }
                        .sheet(isPresented: $isAddingChild) {
                            AddChildView()
                        }
                        .refreshable {
                            viewModel.refreshChildStatus()
                            reportRefreshID = UUID()
                        }
                        .scrollIndicators(.hidden)
                    }
                    .navigationBarHidden(true)
                    .background(Color.roleBackground.ignoresSafeArea())
                }
                .overlayPreferenceValue(HintAnchorKey.self) { anchor in
                    if let anchor = anchor, showHelpHint {
                        GeometryReader { overlayGeometry in
                            let anchorPoint = overlayGeometry[anchor]
                            
                            HintBubbleView(message: "Если что-то не работает, проверьте все настройки у Ваших детей")
                                .position(
                                    // надо сделать более динамические вычисления
                                    x: anchorPoint.x - 176,
                                    y: anchorPoint.y + 110
                                )
                                .transition(.scale(scale: 0.8, anchor: .topTrailing).combined(with: .opacity))
                                .frame(maxWidth: UIScreen.main.bounds.width / 2)
                        }
                    }
                }
            }
            .navigationDestination(
                isPresented: $navigateToNotifications,
                destination: { NotificationView(showNavigationBar: $isTabBarVisible) }
            )
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("ParentNotificationReceived"))) { _ in
                handleCommandUpdate()
            }
            .navigationDestination(
                isPresented: $showHelp,
                destination: { HelpView(showNavigationBar: $isTabBarVisible) }
            )
            .onAppear {
                checkIfShouldShowHint()
            }
            .onDisappear {
                showHelpHint = false
            }
        }
    }
    
    private func checkIfShouldShowHint() {
        let now = Date()
        let oneWeekInSeconds: TimeInterval = 7 * 24 * 60 * 60
        
        // Получаем дату последнего показа из UserDefaults
        if let lastShowDate = UserDefaults.standard.object(forKey: lastHintShowDateKey) as? Date {
            if now.timeIntervalSince(lastShowDate) >= oneWeekInSeconds {
                showHintAndSaveDate()
            } else {
                print("ℹ️ Подсказка для 'Help' была показана недавно. Пропускаем.")
            }
        } else {
            showHintAndSaveDate()
        }
    }
    
    private func showHintAndSaveDate() {
        print("💡 Показываем подсказку для 'Help'.")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.spring()) {
                showHelpHint = true
            }
            
            // Сохраняем текущую дату как дату последнего показа
            UserDefaults.standard.set(Date(), forKey: lastHintShowDateKey)
            
            // Автоматически скрываем подсказку через 7 секунд
            DispatchQueue.main.asyncAfter(deadline: .now() + 8.0) {
                withAnimation(.spring()) {
                    showHelpHint = false
                }
            }
        }
    }
    
    private func handleCommandUpdate() {
        print("🔔 Получено уведомление, обновляем флаг...")
        
        Task {
            await notificationViewModel.loadAllNotifications()
        }
    }
}
