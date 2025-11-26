//
//  EmptyStateView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 26.11.2025.
//

import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "person.3.fill") // ... ваш UI без изменений ...
            Text("Дети еще не добавлены")
            Text("Нажмите кнопку ниже, чтобы добавить первое устройство ребенка.")
            
            // 2. Заменяем Button на NavigationLink
            NavigationLink(destination: AddChildView()) {
                // Label для NavigationLink выглядит как кнопка
                Text("Добавить ребенка")
                    .padding(.horizontal, 30)
                    .padding(.vertical, 10)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.top)
            
            Spacer()
            Spacer()
        }
        .padding()
    }
}
