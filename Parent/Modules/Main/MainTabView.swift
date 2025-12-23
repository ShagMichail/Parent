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
    
    @State private var selectedTab: Tab = .location
    
    // --- ГЛАВНЫЕ СОСТОЯНИЯ (ЖИВУТ ЗДЕСЬ) ---
    @State private var showBlockOverlay = false
    @Namespace private var animation
    
    init() {
        let appearance = UITabBarAppearance()
        
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        
        appearance.shadowImage = nil
        appearance.shadowColor = UIColor.black.withAlphaComponent(0.1)
        
        let itemAppearance = UITabBarItemAppearance()
        
        itemAppearance.normal.iconColor = UIColor.gray
        itemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.gray]
        
        let activeColor = UIColor(named: "accent")
        itemAppearance.selected.iconColor = activeColor
        itemAppearance.selected.titleTextAttributes = [.foregroundColor: activeColor ?? .accent]
        
        appearance.stackedLayoutAppearance = itemAppearance
        appearance.inlineLayoutAppearance = itemAppearance
        appearance.compactInlineLayoutAppearance = itemAppearance
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                LocationView(stateManager: stateManager, cloudKitManager: cloudKitManager)
                    .tabItem { Label("Локация", image: "location-tab") }
                    .tag(Tab.location)
                
                AISummaryView()
                    .tabItem { Label("AI-Сводка", image: "shield-tick-tab") }
                    .tag(Tab.summary)
                
                ParentDashboardView(
                    showBlockOverlay: $showBlockOverlay,
                    animation: animation
                )
                .tabItem { Label("Дети", image: "profile-user-tab") }
                .tag(Tab.children)
                
                Text("Настройки")
                    .tabItem { Label("Настройки", image: "setting-tab") }
                    .tag(Tab.settings)
            }
            .accentColor(.accent)
            .blur(radius: showBlockOverlay ? 5 : 0)
            
            if showBlockOverlay {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture { closeOverlay() }
                    .transition(.opacity)
                ZStack(alignment: .topLeading) {
                    VStack(spacing: 24) {
                        ActionCard(model: ActionCardModel(
                            title: "Блокировать",
                            icon: "lock-command",
                            status: viewModel.isSelectedChildBlocked ? "Вкл." : "Выкл.",
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
                                    Image(viewModel.isSelectedChildBlocked ? "unlock-command" : "lock-command")
                                        .resizable().frame(width: 16, height: 16)
                                    Text(viewModel.isSelectedChildBlocked ? "Разблокировать" : "Блокировать")
                                        .font(.system(size: 16, weight: .regular, design: .rounded))
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
