//
//  PinContentView.swift
//  Parent
//
//  Created by Michail Shagovitov on 23.12.2025.
//

import SwiftUI

struct PinContentView: View {
    let model: PinContentViewModel

    var body: some View {
        ChildAnnotationView(
            model: ChildAnnotationViewModel(
                name: model.child.name,
                gender: model.child.gender,
                isSelected: model.isSelected
            )
        )
        .onTapGesture { model.onTap() }
    }
}
