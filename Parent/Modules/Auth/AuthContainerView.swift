//
//  AuthContainerView.swift
//  Parent
//
//  Created by Michail Shagovitov on 22.12.2025.
//

import SwiftUI

struct AuthContainerView: View {
    
    let initialMode: AuthMode
    
    // State, который хранит ТЕКУЩИЙ режим
    @State private var mode: AuthMode

    init(initialMode: AuthMode) {
        self.initialMode = initialMode
        self._mode = State(initialValue: initialMode)
    }

    var body: some View {
        AuthFormView(mode: $mode)
    }
}
