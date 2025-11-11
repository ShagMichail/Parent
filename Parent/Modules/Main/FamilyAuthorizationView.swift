//
//  FamilyAuthorizationView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 11.11.2025.
//

import SwiftUI

struct FamilyAuthorizationView: View {
    @EnvironmentObject private var familyManager: FamilyManager
    @State private var isAuthorizing = false

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.3.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)

            Text("Доступ к Family Sharing")
                .font(.title2)
                .bold()

            Text("Для работы приложения необходим доступ к управлению экранным временем через Family Sharing")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)

            Button {
                requestFamilyAuthorization()
            } label: {
                if isAuthorizing {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Предоставить доступ")
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isAuthorizing)
        }
        .padding()
    }

    private func requestFamilyAuthorization() {
        isAuthorizing = true

        Task {
            do {
                try await familyManager.setupFamilySharing()
            } catch {
                print("Ошибка авторизации Family Sharing: \(error)")
            }

            await MainActor.run {
                isAuthorizing = false
            }
        }
    }
}
