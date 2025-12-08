//
//  LocationAnnotationView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 02.12.2025.
//

import SwiftUI

// MARK: - Вспомогательные View
struct LocationAnnotationView: View {
    let location: ChildLocation
    let isCurrent: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: isCurrent ? "location.fill" : "location")
                .font(isCurrent ? .title2 : .body)
                .foregroundColor(isCurrent ? .red : .blue)
                .padding(8)
                .background(
                    Circle()
                        .fill(Color.white)
                        .shadow(radius: 2)
                )
            
            if isCurrent {
                Text("Сейчас")
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Capsule().fill(Color.red))
                    .foregroundColor(.white)
                    .offset(y: -4)
            }
        }
    }
}
