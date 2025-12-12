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
    @EnvironmentObject var cloudKitManager: CloudKitManager
    @State private var isAddingChild = false
    @State private var showDivider = false
    @State private var reportRefreshID = UUID()
    @EnvironmentObject var viewModel: ParentDashboardViewModel
    @Binding var showBlockOverlay: Bool
    var animation: Namespace.ID

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                NavigationBar(
                    model: NavigationBarModel(
                        mainTitle: "Дети",
                        hasNotification: true,
                        hasNewNotification: true,
                        onBackTap: {},
                        onNotificationTap: {},
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
                        
                        if let selectedChild = viewModel.selectedChild {
                            ChildDashboardDetailView(showBlockOverlay: $showBlockOverlay, animation: animation)
                                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                                .id(reportRefreshID)
                                .onAppear {
                                    viewModel.refreshChildStatus()
                                }
                        } else {
                            ContentUnavailableView("Добавьте ребенка", systemImage: "person.3.fill", description: Text("Нажмите на '+' чтобы добавить первого ребенка."))
                        }
                    }
                    .padding(.bottom, 20)
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
            .background(Color.roleBackround.ignoresSafeArea())
        }
        .id(viewModel.selectedChild?.id)
    }
}
