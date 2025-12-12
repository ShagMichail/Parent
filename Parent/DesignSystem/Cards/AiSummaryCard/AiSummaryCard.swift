//
//  AiSummaryCard.swift
//  Parent
//
//  Created by Michail Shagovitov on 10.12.2025.
//

import SwiftUI

struct AiSummaryCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(spacing: 10) {
                Image("star-ai")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(.white)
                
                Text("AI Сводка за сегодня")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundStyle(.white)
            }
            .foregroundColor(.white)
            
            Text("Маша провела весь день продуктивно. Экранное время снизилось на 12% по сравнению со вчерашним днём. Основное время было потрачено на образовательные приложения.")
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .frame(maxWidth: .infinity)
                .foregroundStyle(.white)
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 20)
        .background(
            LinearGradient(
                colors: [Color.gradientStart, Color.gradientEnd],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
    }
}
