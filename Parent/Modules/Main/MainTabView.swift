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
    // Получаем ViewModel, чтобы знать статус блокировки и вызывать методы
    @EnvironmentObject var viewModel: ParentDashboardViewModel
    
    @State private var selectedTab: Tab = .summary
    
    // --- ГЛАВНЫЕ СОСТОЯНИЯ (ЖИВУТ ЗДЕСЬ) ---
    @State private var showBlockOverlay = false // Управляет показом оверлея
    @Namespace private var animation            // Магия перемещения карточки
    
    init() {
        // 1. Создаем объект настроек
        let appearance = UITabBarAppearance()
        
        // 2. Делаем фон непрозрачным и белым
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        
        // 3. Настраиваем Тень (полоску сверху)
        // В iOS нативный TabBar поддерживает "Shadow Image" (обычно это тонкая линия)
        // Чтобы сделать её похожей на тень, делаем светло-серый цвет
        appearance.shadowImage = nil // Сбрасываем картинку
        appearance.shadowColor = UIColor.black.withAlphaComponent(0.1) // Цвет линии/тени
        
        // 4. Настраиваем иконки и текст
        let itemAppearance = UITabBarItemAppearance()
        
        // Неактивное состояние (Серый)
        itemAppearance.normal.iconColor = UIColor.gray
        itemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.gray]
        
        // Активное состояние (Ваш акцентный цвет, например фиолетовый)
        // Если у вас есть Color.accent, используйте UIColor(named: "AccentColor")
        let activeColor = UIColor(named: "accent") // Ваш фиолетовый
        itemAppearance.selected.iconColor = activeColor
        itemAppearance.selected.titleTextAttributes = [.foregroundColor: activeColor ?? .accent]
        
        // Применяем настройки к иконкам
        appearance.stackedLayoutAppearance = itemAppearance
        appearance.inlineLayoutAppearance = itemAppearance
        appearance.compactInlineLayoutAppearance = itemAppearance
        
        // 5. Применяем настройки глобально
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        ZStack {
            // ===================================
            // СЛОЙ 1: ПРИЛОЖЕНИЕ (ТАБЫ)
            // ===================================
            TabView(selection: $selectedTab) {
                Text("Локация")
                    .tabItem { Label("Локация", image: "location-tab") }
                    .tag(Tab.location)
                
                AISummaryView()
                    .tabItem { Label("AI-Сводка", image: "shield-tick-tab") }
                    .tag(Tab.summary)
                
                // Передаем Binding и Namespace вниз в иерархию
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
            // ✅ БЛЮРИМ ВСЁ ПРИЛОЖЕНИЕ (ВКЛЮЧАЯ TABBAR)
            .blur(radius: showBlockOverlay ? 5 : 0)
            
            // ===================================
            // СЛОЙ 2: ОВЕРЛЕЙ (ПОВЕРХ TABBAR)
            // ===================================
            if showBlockOverlay {
                // Темный фон
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture { closeOverlay() }
                    .transition(.opacity)
                ZStack(alignment: .topLeading) {
                    VStack(spacing: 24) {
                        // КАРТОЧКА (Прилетает снизу через matchedGeometryEffect)
                        ActionCard(model: ActionCardModel(
                            title: "Блокировать",
                            icon: "lock-command",
                            status: viewModel.isSelectedChildBlocked ? "Вкл." : "Выкл.",
                            action: { closeOverlay() }
                        ))
                        .frame(width: (UIScreen.main.bounds.width - 16 * 3) / 2)
                        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
                        .matchedGeometryEffect(id: "blockCard", in: animation)
                        
                        // КНОПКИ УПРАВЛЕНИЯ
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
