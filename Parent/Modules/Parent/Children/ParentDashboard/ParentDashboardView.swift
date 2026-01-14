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

struct ParentDashboardView: View {
    @EnvironmentObject var cloudKitManager: CloudKitManager
    @State private var isAddingChild = false
    @State private var showDivider = false
    @State private var reportRefreshID = UUID()
    @State private var navigateToNotifications = false
    @EnvironmentObject var viewModel: ParentDashboardViewModel
    @EnvironmentObject var notificationViewModel: NotificationViewModel
    @Binding var isTabBarVisible: Bool
    @Binding var showBlockOverlay: Bool
    var animation: Namespace.ID

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                NavigationBar(
                    model: NavigationBarModel(
                        mainTitle: String(localized: "Children"),
                        hasNotification: true,
                        hasNewNotification: notificationViewModel.hasNewNotificationForSelectedChild,
                        onBackTap: {},
                        onNotificationTap: {
                            navigateToNotifications.toggle()
                            isTabBarVisible.toggle()
                        },
                        onConfirmTap: {}
                    )
                )
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
            .navigationDestination(
                isPresented: $navigateToNotifications,
                destination: { NotificationView(showNavigationBar: $isTabBarVisible) }
            )
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("ParentNotificationReceived"))) { _ in
                handleCommandUpdate()
            }
        }
        .id(viewModel.selectedChild?.id)
    }
    
    private func handleCommandUpdate() {
            print("🔔 Получено уведомление, обновляем флаг...")
            
            Task {
                await notificationViewModel.loadAllNotifications()
            }
        }
}
