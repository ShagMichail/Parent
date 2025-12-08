//
//  ChildDashboardDetailView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 04.12.2025.
//

import SwiftUI

struct ChildDashboardDetailView: View {
    @ObservedObject var viewModel: ParentDashboardViewModel
    
    private var actionColumns: [GridItem] {
        let screenWidth = UIScreen.main.bounds.width
        let spacing: CGFloat = 16
        let columnWidth = (screenWidth - spacing * 3) / 2
        
        return [
            GridItem(.fixed(columnWidth), spacing: spacing),
            GridItem(.fixed(columnWidth), spacing: spacing)
        ]
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Местоположение
            InfoCard(
                model: InfoCardModel(
                    title: "Местоположение",
                    icon: "current-location",
                    location: "ул. Механизатора д. 13",
                    status: "Онлайн",
                    statusColor: .green
                )
            )
            
            // Топ приложений
            TopAppsView(
                models: [
                    TopAppsViewModel(
                        icon: "person",
                        nameApps: "Telegram",
                        time: "1 ч 22 мин"
                    )
                    ,
                    TopAppsViewModel(
                        icon: "person",
                        nameApps: "Telegram",
                        time: "1 ч 22 мин"
                    )
                ]
            )
            
            // Действия
            Text("Действия")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.blackText)
            
            LazyVGrid(columns: actionColumns, spacing: 16) {
                ActionCard(
                    model: ActionCardModel(
                        title: viewModel.isSelectedChildBlocked ? "Разблокировать" : "Блокировать",
                        icon: "lock-command",
                        status: viewModel.isSelectedChildBlocked ? "Вкл." : "Выкл.",
                        action: {
                    viewModel.toggleBlock()
                }))
                .disabled(viewModel.isCommandInProgressForSelectedChild)
                .opacity(viewModel.isCommandInProgressForSelectedChild ? 0.6 : 1.0)
                // Анимация применяется ЗДЕСЬ, а не в ViewModel
                .animation(.easeInOut(duration: 0.3), value: viewModel.isCommandInProgressForSelectedChild)
                .animation(.easeInOut(duration: 0.3), value: viewModel.isSelectedChildBlocked)
                
                ActionCard(model: ActionCardModel(title: "Фокусировать", icon: "focus-command", status: "Выкл.", action: {}))
                ActionCard(model: ActionCardModel(title: "Приложения", icon: "apps-command", showsArrow: true, action: {}))
                ActionCard(model: ActionCardModel(title: "Сайты", icon: "web-command", showsArrow: true, action: {}))
            }
        }
        .padding(.horizontal, 20)
    }
}
