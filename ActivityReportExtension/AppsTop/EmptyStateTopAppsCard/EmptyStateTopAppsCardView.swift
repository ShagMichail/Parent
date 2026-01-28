//
//  EmptyStateTopAppsCardView.swift
//  Parent
//
//  Created by Michail Shagovitov on 16.12.2025.
//

import SwiftUI

struct EmptyStateTopAppsCardView: View {
    let model: EmptyStateTopAppsCardViewModel
    
    var body: some View {
            VStack(alignment: .center, spacing: 10) {
                
                Image(model.iconName)
                    .resizable()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.gray.opacity(0.5))
                
                Text(model.message)
                    .font(.custom("Inter-Regular", size: 16))
                    .foregroundColor(.timestamps)
                    .multilineTextAlignment(.center)
            }
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.white)
                }
            )
        .frame(maxWidth: .infinity)
    }
}
