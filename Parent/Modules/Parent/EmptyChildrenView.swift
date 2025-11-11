//
//  EmptyChildrenView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 11.11.2025.
//

import SwiftUI

struct EmptyChildrenView: View {
    @Binding var showingAddChild: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.2")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Добавьте ребенка")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Для начала управления экранным временем добавьте устройство ребенка")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 40)
            
            Button("Добавить ребенка") {
                showingAddChild = true
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.top, 20)
        }
    }
}
