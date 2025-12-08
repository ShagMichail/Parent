//
//  MainButton.swift
//  Parent
//
//  Created by Михаил Шаговитов on 03.12.2025.
//

import SwiftUI

struct MainButton: View {
    let model: MainButtonModel

    var body: some View {
        Text(model.title)
            .font(model.font)
            .foregroundColor(model.foregroundColor)
            .frame(maxWidth: .infinity) 
            .padding()
            .background(
                RoundedRectangle(cornerRadius: model.cornerRadius)
                    .fill(model.background)
                    .stroke(model.strokeColor, lineWidth: model.strokeLineWidth)
            )
    }
}
