//
//  PinContentView.swift
//  Parent
//
//  Created by Michail Shagovitov on 16.12.2025.
//

import SwiftUI

struct PinContentView: View {
    let child: Child
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        ChildAnnotationView(
            name: child.name,
            isSelected: isSelected
        )
        .onTapGesture { onTap() }
    }
}
