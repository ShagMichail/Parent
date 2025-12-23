//
//  InfoRow.swift
//  Parent
//
//  Created by Michail Shagovitov on 23.12.2025.
//

import SwiftUI

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(.blackText)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(.timestamps)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 20)
    }
}
