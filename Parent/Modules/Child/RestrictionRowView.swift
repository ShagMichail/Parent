//
//  RestrictionRowView.swift
//  Parent
//
//  Created by Michail Shagovitov on 29.12.2025.
//

import SwiftUI

struct RestrictionRowView: View {
    let item: RestrictionItem
    
    var body: some View {
        HStack(spacing: 15) {
            Image(item.iconName)
                .resizable()
                .frame(width: 45, height: 45)
            
            VStack(alignment: .leading) {
                Text(item.title)
                    .font(.custom("Inter-Medium", size: 16))
                    .foregroundColor(.blackText)
                HStack(spacing: 4) {
                    Text(item.description)
                    if let count = item.count {
                        Text("\(count)")
                    }
                }
                .font(.custom("Inter-Regular", size: 12))
                .foregroundColor(.strokeTextField)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 20)
        .padding(.horizontal, 10)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.white)
            }
        )
        .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 2)
        .contentShape(Rectangle())
    }
}
