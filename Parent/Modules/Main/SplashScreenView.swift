//
//  SplashScreenView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 01.12.2025.
//

import SwiftUI

struct SplashScreenView: View {
    var body: some View {
        ZStack {
            Color.accent.ignoresSafeArea()
            VStack {
                Image("lock")
                    .font(.system(size: 120))
                    .foregroundColor(.white)
                Text("Родительский контроль")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
        }
    }
}

