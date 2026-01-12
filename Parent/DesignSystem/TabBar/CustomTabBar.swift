//
//  CustomTabBar.swift
//  Parent
//
//  Created by Michail Shagovitov on 12.01.2026.
//

import SwiftUI

// Определяем наши табы. Вы можете использовать ваш enum `Tab`
enum CustomTab: String, CaseIterable {
    case location
    case summary
    case children
    case settings

    var iconName: String {
        switch self {
        case .location: return "location-tab"
        case .summary: return "shield-tick-tab"
        case .children: return "profile-user-tab"
        case .settings: return "setting-tab"
        }
    }
    
    var iconText: String {
        switch self {
        case .location: return String(localized: "Location")
        case .summary: return String(localized: "AI-Summary")
        case .children: return String(localized: "Children")
        case .settings: return String(localized: "Settings")
        }
    }
}

struct CustomTabBar: View {
    // Binding к выбранному табу, чтобы родительская View знала о смене
    @Binding var selectedTab: CustomTab
    
    // Цвета
    private let activeColor = Color.accent
    private let inactiveColor = Color.blackText
    
    var body: some View {
        HStack {
            // Проходим по всем возможным табам
            ForEach(CustomTab.allCases, id: \.rawValue) { tab in
                Spacer()
                // Кнопка для каждого таба
                VStack(spacing: 4) {
                    Image(tab.iconName)
                        .font(.title2)
                    
                    Text(tab.iconText)
                        .font(.custom("Inter-Medium", size: 10))
                }
                .foregroundColor(selectedTab == tab ? activeColor : inactiveColor)
                .onTapGesture {
                    withAnimation(.easeInOut) {
                        selectedTab = tab
                    }
                }
                Spacer()
            }
        }
        .frame(height: 80) // Задаем высоту
        .background(Color.white)
        .shadow(color: .black.opacity(0.1), radius: 10, y: -5)
        .padding(.bottom, -20)
        .ignoresSafeArea(.all, edges: .bottom)
    }
}
