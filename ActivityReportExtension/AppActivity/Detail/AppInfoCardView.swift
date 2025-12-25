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
        return String(localized: "Is unknown")
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("General information")
                .font(.custom("Inter-SemiBold", size: 20))
                .foregroundColor(.blackText)
            
            VStack(spacing: 0) {
                InfoRow(title: String(localized: "Title"), value: detail.application.localizedDisplayName ?? String(localized: "Is unknown"))
                Divider()
                    .padding(.horizontal, 10)
                InfoRow(title: String(localized: "Category"), value: detail.category.localizedDisplayName ?? String(localized: "Is unknown"))
            }
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
        }
        .padding(.horizontal, 20)
    }
}
