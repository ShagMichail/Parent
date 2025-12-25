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
                
                Text("AI Summary for today")
                    .font(.custom("Inter-Medium", size: 18))
                    .foregroundStyle(.white)
            }
            .foregroundColor(.white)
            
            Text("Masha spent the whole day productively. Screen time decreased by 12% compared to yesterday. Most of the time was spent on educational applications.")
                .font(.custom("Inter-Regular", size: 16))
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
