//
//  WaitingForParentView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 26.11.2025.
//

import SwiftUI

struct WaitingForParentView: View {
    let invitationCode: String
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Покажите этот код родителю:")
                .font(.headline)
            
            Text(invitationCode)
                .font(.system(size: 50, weight: .bold, design: .monospaced))
                .padding()
                .background(Color.gray.opacity(0.15))
                .cornerRadius(12)
                .textSelection(.enabled) // Позволяет скопировать код
            
            VStack {
                ProgressView("Ожидание подтверждения от родителя...")
                Text("Этот экран закроется автоматически.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.top)
        }
        .padding(30)
    }
}
