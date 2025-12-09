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
                ForEach(apps) { model in
                    HStack(spacing: 15) {
                        if let token = model.token {
                            Label(token)
                                .labelStyle(.iconOnly)
                                .scaleEffect(1.2)
                                .frame(width: 32, height: 32)
                                .clipShape(RoundedRectangle(cornerRadius: 6)) // Скругление как у iOS иконок
                        } else {
                            // Заглушка, если токена нет
                            Image(systemName: "app.dashed")
                                .resizable()
                                .frame(width: 32, height: 32)
                                .foregroundColor(.gray) // тут цвет
                        }
                        Text(model.name)
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(Color(red: 0.122, green: 0.161, blue: 0.216)) // тут цвет
                        
                        Spacer()
                        Text(formatDuration(model.duration))
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(Color(red: 0.800, green: 0.800, blue: 0.800)) // тут цвет
                    }
                    .padding(.horizontal, 10)
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
        formatter.unitsStyle = .abbreviated // "1 ч 22 мин"
        var calendar = Calendar.current
        // 2. Принудительно ставим русскую локаль
        calendar.locale = Locale(identifier: "ru_RU")
        // 3. Передаем календарь форматтеру
        formatter.calendar = calendar
        return formatter.string(from: duration) ?? "0 мин"
    }
}
