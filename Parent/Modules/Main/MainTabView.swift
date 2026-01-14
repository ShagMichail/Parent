//
//  MainTabView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 04.12.2025.
//

import SwiftUI

// Enum для управления вкладками
private enum Tab {
    case location, summary, children, settings
}

struct MainTabView: View {
    @EnvironmentObject var viewModel: ParentDashboardViewModel
    @EnvironmentObject var stateManager: AppStateManager
    @EnvironmentObject var cloudKitManager: CloudKitManager
    
//    @State private var selectedTab: Tab = .location
    @State private var selectedTab: CustomTab = .location
    @State private var isTabBarVisible: Bool = true
    // --- ГЛАВНЫЕ СОСТОЯНИЯ (ЖИВУТ ЗДЕСЬ) ---
    @State private var showBlockOverlay = false
    @Namespace private var animation
    
    var body: some View {
        ZStack(alignment: .bottom) {
//            TabView(selection: $selectedTab) {
//                LocationView(stateManager: stateManager, cloudKitManager: cloudKitManager)
//                    .tabItem { Label("Location", image: "location-tab") }
//                    .tag(Tab.location)
//                
//                AISummaryView()
//                    .tabItem { Label("AI-Summary", image: "shield-tick-tab") }
//                    .tag(Tab.summary)
//                
//                ParentDashboardView(
//                    showBlockOverlay: $showBlockOverlay,
//                    animation: animation
//                )
//                .tabItem { Label("Children", image: "profile-user-tab") }
//                .tag(Tab.children)
//                
//                Text("Settings")
//                    .tabItem { Label("Settings", image: "setting-tab") }
//                    .tag(Tab.settings)
//            }
//            .accentColor(.accent)
//            .blur(radius: showBlockOverlay ? 5 : 0)
            
            
            Group {
                switch selectedTab {
                case .location:
                    LocationView(
                        stateManager: stateManager,
                        cloudKitManager: cloudKitManager,
                        isTabBarVisible: $isTabBarVisible
                    )
                case .summary:
                    AISummaryView(
                        isTabBarVisible: $isTabBarVisible
                    )
                case .children:
                    ParentDashboardView(
                        isTabBarVisible: $isTabBarVisible,
                        showBlockOverlay: $showBlockOverlay,
                        animation: animation
                    )
                case .settings:
                    SettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            if isTabBarVisible {
                CustomTabBar(selectedTab: $selectedTab)
                    .transition(.move(edge: .bottom)) // Добавим анимацию появления/исчезновения
            }
            
            // --- СЛОЙ 2: НАШ КАСТОМНЫЙ TABBAR ---
//            CustomTabBar(selectedTab: $selectedTab)
            
            
            if showBlockOverlay {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture { closeOverlay() }
                    .transition(.opacity)
                ZStack(alignment: .topLeading) {
                    VStack(spacing: 24) {
                        ActionCard(model: ActionCardModel(
                            title: String(localized: "Block"),
                            icon: viewModel.isSelectedChildBlocked ? "lock-command" : "unlock-command",
                            status: viewModel.isSelectedChildBlocked ? String(localized: "On.") : String(localized: "Off."),
                            action: { closeOverlay() }
                        ))
                        .frame(width: (UIScreen.main.bounds.width - 16 * 3) / 2)
                        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
                        .matchedGeometryEffect(id: "blockCard", in: animation)
                        
                        VStack(spacing: 12) {
                            Button {
                                viewModel.toggleBlock()
                                closeOverlay()
                            } label: {
                                HStack(spacing: 6) {
                                    Text(viewModel.isSelectedChildBlocked ? "Unblock" : "Block")
                                        .font(.custom("Inter-Regular", size: 16))
                                }
                                .padding(.vertical, 20)
                                .padding(.horizontal, 10)
                                .background(Color.white).cornerRadius(16)
                                .foregroundColor(viewModel.isSelectedChildBlocked ? .green : .red)
                            }
                        }
                        .frame(maxWidth: 250)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .zIndex(2)
                }
            }
        }
    }
    
    private func closeOverlay() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            showBlockOverlay = false
        }
    }
}
