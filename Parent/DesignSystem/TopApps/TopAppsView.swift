//
//  TopAppsView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 05.12.2025.
//

import SwiftUI

struct TopAppsView: View {
    let models: [TopAppsViewModel]
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Топ приложений за сегодня")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.blackText)
            
            VStack(spacing: 16) {
                ForEach(models) { model in
                    HStack(spacing: 15) {
                        Image(model.icon)
                            .resizable()
                            .frame(width: 32, height: 32)
                        Text(model.nameApps)
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(.blackText)
                        
                        Spacer()
                        Text(model.time)
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(.plusForderground)
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
            .shadow(
                color: Color.black.opacity(0.08),
                radius: 8,
                x: 0,
                y: 4
            )
        }
    }
}
