//
//  ActionCard.swift
//  Parent
//
//  Created by Михаил Шаговитов on 05.12.2025.
//

import SwiftUI

struct ActionCard: View {
    let model: ActionCardModel
    
    var body: some View {
        Button(action: model.action) {
            VStack(alignment: .leading) {
                Image(model.icon)
                    .resizable()
                    .frame(width: 26, height: 26)
                    .padding(.bottom, 20)
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text(model.title)
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.blackText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        if model.showsArrow ?? false {
                            Image(systemName: "chevron.right")
                                .resizable()
                                .frame(width: 10, height: 16)
                                .foregroundStyle(.plusForderground)
                        }
                    }
                    if let status = model.status {
                        Text(status)
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.plusForderground)
                    }
                }
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 20)
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
        .buttonStyle(.plain)
    }
}
