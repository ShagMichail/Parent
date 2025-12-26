//
//  CustomNavigationBar.swift
//  Parent
//
//  Created by Михаил Шаговитов on 05.12.2025.
//

import SwiftUI

struct NavigationBar: View {
    let model: NavigationBarModel
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                // Аватарка и приветствие
                HStack(spacing: 12) {
                    if let mainTitle = model.mainTitle {
                        Text(mainTitle)
                            .font(.custom("Inter-Medium", size: 24))
                            .foregroundColor(.blackText)
                    } else if model.chevronBackward ?? false {
                        Button(action: model.onBackTap) {
                            Image(systemName: "chevron.backward")
                                .font(.headline)
                                .foregroundColor(Color.blackText)
                                .frame(width: 24, height: 24)
                        }
                    }
                    
                }
                
                Spacer()
                
                HStack(alignment: .center) {
                    if let subTitle = model.subTitle {
                        Text(subTitle)
                            .font(.custom("Inter-Regular", size: 16))
                            .foregroundColor(.blackText)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .multilineTextAlignment(.center)
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
                } else if model.hasConfirm ?? false {
                    Button(action: model.onConfirmTap) {
                        Image("chevron-up")
                            .font(.headline)
                            .foregroundColor(Color.blackText)
                            .frame(width: 24, height: 24)
                    }
                } else {
                    Button(action: {}) {
                        Color.clear
                            .frame(width: 24, height: 24)
                    }
                }
            }
            .frame(height: 70)
        }
        .padding(.horizontal, 20)
        .background(
            Color.roleBackground
                .ignoresSafeArea(edges: .top)
        )
    }
}

#Preview {
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
    NavigationBar(
        model: NavigationBarModel(
            chevronBackward: true,
            subTitle: "Редактирование времени фокусировки",
            onBackTap: {},
            onNotificationTap: {},
            onConfirmTap: {}
        )
    )
}
