//
//  FloatingActionButton.swift
//  Parent
//
//  Created by Michail Shagovitov on 23.12.2025.
//

import SwiftUI

struct FloatingActionButton: View {
    let model: FloatingActionButtonModel

    var body: some View {
        Button(action: model.action) {
            ZStack {
                Image(model.iconName)
                    .resizable()
                    .font(.title3)
                    .foregroundColor(.accent)
                    .frame(width: 24, height: 24)
            }
            .frame(width: 50, height: 50)
            .background(
                Circle()
                    .stroke(.accent, lineWidth: 1)
            )
        }
    }
}
