//
//  MainTabView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 04.12.2025.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var stateManager: AppStateManager
    @State private var selectedTab: Tab = .children
    
    var body: some View {
        // TabView - основа нашей навигации
        TabView(selection: $selectedTab) {
            
            // --- ВКЛАДКА 1: Локация ---
            Text("Локация")
                .tabItem {
                    Label("Локация", image: "location-tab")
                }
                .tag(Tab.location)
            
            // --- ВКЛАДКА 2: Сводка ---
            Text("Экран AI-Сводки")
                .tabItem {
                    Label("AI-Сводка", image: "shield-tick-tab")
                }
                .tag(Tab.summary)
            
            // --- ВКЛАДКА 3: Дети (старый экран) ---
            ParentDashboardView(stateManager: stateManager)
                .tabItem {
                    Label("Дети", image: "profile-user-tab")
                }
                .tag(Tab.children)
            
            // --- ВКЛАДКА 4: Настройки ---
            Text("Экран Настроек")
                .tabItem {
                    Label("Настройки", image: "setting-tab")
                }
                .tag(Tab.settings)
                .toolbar(.hidden, for: .tabBar)
        }
        // Задаем основной цвет для иконок таб бара
        .accentColor(.accent)
    }
}

// Enum для управления вкладками
private enum Tab {
    case location, summary, children, settings
}
