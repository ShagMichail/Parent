//
//  CustomNavigationBar.swift
//  Parent
//
//  Created by Михаил Шаговитов on 05.12.2025.
//

import SwiftUI

struct NavigationBar: View {
    let model: NavigationBarModel
//    let showDivider: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                // Аватарка и приветствие
                HStack(spacing: 12) {
                    if let mainTitle = model.mainTitle {
                        Text(mainTitle)
                            .font(.system(size: 24, weight: .medium, design: .rounded))
                            .foregroundColor(.blackText)
                    } else if model.chevronBackward ?? false {
                        Button(action: model.onBackTap) {
                            Image(systemName: "chevron.backward")
                                .font(.headline)
                                .foregroundColor(Color.blackText)
                        }
                    }
                    
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    if let subTitle = model.subTitle {
                        Text(subTitle)
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(.blackText)
                    }
                }
                
                Spacer()
                
                // Кнопки действий
                if model.hasNotification ?? false {
                    HStack(spacing: 12) {
                        // Кнопка уведомлений
                        Button(action: model.onNotificationTap) {
                            ZStack {
                                Image("notification")
                                    .font(.title3)
                                    .foregroundColor(.primary)
                                
                                if model.hasNewNotification ?? false {
                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: 8, height: 8)
                                        .offset(x: 8, y: -8)
                                }
                            }
                            .frame(width: 50, height: 50)
                            .background(
                                Circle()
                                    .stroke(.accent, lineWidth: 1)
                            )
                        }
                    }
                }
            }
            .frame(height: 70)
//            if showDivider {
//                Rectangle()
//                    .fill(Color.gray.opacity(0.2))
//                    .frame(height: 1)
//                    .transition(.opacity)
//            }
        }
        .padding(.horizontal, 20)
        .background(
            Color.roleBackround
                .ignoresSafeArea(edges: .top)
        )
    }
}
//
//#Preview {
//    NavigationBar(
//        model: NavigationBarModel(
//            mainTitle: "Дети",
//            hasNotification: true,
//            hasNewNotification: true,
//            onBackTap: {},
//            onNotificationTap: {}
//        )
//    )
//    NavigationBar(
//        model: NavigationBarModel(
//            chevronBackward: true,
//            subTitle: "Ltnb",
//            onBackTap: {},
//            onNotificationTap: {}
//        )
//    )
//}
