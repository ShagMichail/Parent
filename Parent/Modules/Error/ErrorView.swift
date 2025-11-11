//
//  ErrorView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 11.11.2025.
//

import SwiftUI

struct ErrorView: View {
    let error: String
    @EnvironmentObject private var authManager: AuthenticationManager

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.orange)

            Text("Ошибка настройки")
                .font(.title2)
                .bold()

            Text(error)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)

            Button("Повторить") {
                authManager.checkAuthorization()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
