//
//  LoginView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 03.12.2025.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var stateManager: AppStateManager
    @EnvironmentObject var authService: AuthenticationService
    var body: some View {
        AuthFormView(mode: .login)
    }
}
