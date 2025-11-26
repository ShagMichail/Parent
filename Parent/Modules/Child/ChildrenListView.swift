//
//  ChildrenListView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 26.11.2025.
//

import SwiftUI

struct ChildrenListView: View {
    @EnvironmentObject var stateManager: AuthenticationManager

    var body: some View {
        List {
            ForEach(stateManager.children) { child in
                // NavigationLink автоматически создаст стрелочку и переход
                NavigationLink(destination: ChildDetailView(child: child)) {
                    HStack {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.blue)
                        Text(child.name)
                            .font(.headline)
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .listStyle(.insetGrouped) // Используем красивый стиль списка
    }
}
