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
                
                Image(systemName: model.iconName)
                    .font(.system(size: 40))
                    .foregroundColor(.gray.opacity(0.5))
                
                Text(model.message)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
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
