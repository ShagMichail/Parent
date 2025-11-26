//
//  InitialSetupView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 26.11.2025.
//

import SwiftUI

struct InitialSetupView: View {
    let errorMessage: String?
    let onGenerate: () -> Void // Замыкание для действия кнопки
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.badge.key.fill")
                .font(.system(size: 80))
                .foregroundColor(.accentColor)
            
            Text("Создайте приглашение для родителя")
                .font(.title2)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
            
            Text("Будет сгенерирован одноразовый код, который нужно будет ввести на устройстве родителя.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            if let error = errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }
            
            Button("Сгенерировать код", action: onGenerate)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding(.top)
        }
        .padding(30)
    }
}
