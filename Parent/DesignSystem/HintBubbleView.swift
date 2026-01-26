//
//  HintBubbleView.swift
//  Parent
//
//  Created by Michail Shagovitov on 26.01.2026.
//

import SwiftUI

struct HintBubbleView: View {
    let message: String
    
    var body: some View {
        Text(message)
            .font(.custom("Inter-Medium", size: 14))
            .foregroundColor(.blackText)
            .padding()
            .background(
                BubbleShape(direction: .top, tipOffset: 35)
                    .fill(Color.white)
            )
            .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
    }
}
