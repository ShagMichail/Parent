//
//  AppInfoCardView.swift
//  Parent
//
//  Created by Michail Shagovitov on 17.12.2025.
//

import SwiftUI
import FamilyControls
import ManagedSettings

struct AppInfoCardView: View {
    let detail: AppUsageDetail
    
    private var installedDate: String {
        return "Неизвестно"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Общие сведения")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundColor(.blackText)
            
            VStack(spacing: 0) {
                InfoRow(title: "Название", value: detail.application.localizedDisplayName ?? "Неизвестно")
                Divider()
                    .padding(.horizontal, 10)
                InfoRow(title: "Категория", value: detail.category.localizedDisplayName ?? "Неизвестно")
                Divider()
                    .padding(.horizontal, 10)
                InfoRow(title: "Bundle ID", value: detail.application.bundleIdentifier ?? "Неизвестно")
            }
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
        }
        .padding(.horizontal, 20)
    }
}

// InfoRow остается без изменений
struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(.blackText)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(.timestamps)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 20)
    }
}
