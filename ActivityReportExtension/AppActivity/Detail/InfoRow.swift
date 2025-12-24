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
                .font(.custom("Inter-Regular", size: 16))
                .foregroundColor(.blackText)
            
            Spacer()
            
            Text(value)
                .font(.custom("Inter-Regular", size: 16))
                .foregroundColor(.timestamps)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 20)
    }
}
