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
            Text("Топ приложений за сегодня")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(Color(red: 0.122, green: 0.161, blue: 0.216)) // тут цвет
            
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
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundColor(.blackText)
                            
                            Spacer()
                            Text(formatDuration(model.duration))
                                .font(.system(size: 16, weight: .regular, design: .rounded))
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
                            
                            Text("Больше никакое приложение не было активным")
                                .font(.system(size: 16, weight: .regular, design: .rounded))
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
                            message: "Пока устройством не пользовались"
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
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "ru_RU")
        formatter.calendar = calendar
        return formatter.string(from: duration) ?? "0 мин"
    }
}
