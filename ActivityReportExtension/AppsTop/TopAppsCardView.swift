//
//  TopAppsCardView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 08.12.2025.
//

import SwiftUI
import FamilyControls
import DeviceActivity

struct TopAppsCardView: View {
    let apps: [AppReportModel]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Top applications for today")
                .font(.custom("Inter-Medium", size: 16))
                .foregroundColor(.blackText)
            
            VStack(spacing: 16) {
                if !apps.isEmpty {
                    ForEach(apps) { model in
                        HStack(spacing: 15) {
                            if let token = model.token {
                                Label(token)
                                    .labelStyle(.iconOnly)
                                    .scaleEffect(1.2)
                                    .frame(width: 32, height: 32)
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                            } else {
                                Image(systemName: "app.dashed")
                                    .labelStyle(.iconOnly)
                                    .scaleEffect(1.5)
                                    .frame(width: 32, height: 32)
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                                    .foregroundColor(.timestamps)
                            }
                            Text(model.name)
                                .font(.custom("Inter-Regular", size: 16))
                                .foregroundColor(.blackText)
                            
                            Spacer()
                            Text(formatTotalDuration(model.duration))
                                .font(.custom("Inter-Regular", size: 16))
                                .foregroundColor(.timestamps)
                        }
                        .padding(.horizontal, 10)
                    }
                    if apps.count == 1 {
                        HStack(spacing: 15) {
                            Image(systemName: "app.dashed")
                                .labelStyle(.iconOnly)
                                .scaleEffect(1.5)
                                .frame(width: 32, height: 32)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                                .foregroundColor(.timestamps)
                            
                            Text("No other application was active.")
                                .font(.custom("Inter-Regular", size: 16))
                                .foregroundColor(.timestamps)
                                .multilineTextAlignment(.leading)
                            Spacer()
                        }
                        .padding(.horizontal, 10)
                    }
                } else {
                    EmptyStateTopAppsCardView(
                        model: EmptyStateTopAppsCardViewModel(
                            iconName: "moon.zzz.fill",
                            message: String(localized: "The device has not been used yet")
                        )
                    )
                }
            }
            .padding(.vertical, 16)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.white)
                }
            )
        }
    }
}
