//
//  AccessDeniedView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 01.12.2025.
//

import SwiftUI

struct AccessDeniedView: View {
//    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            Text("Access is required")
                .font(.title)
                .fontWeight(.bold)
            
            Text("For the application to work, you must provide access to device management.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Button("Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            
            Button("Exit") {
//                authManager.userRole = .unknown
//                authManager.appState = .roleSelection
            }
            .padding()
            .foregroundColor(.red)
        }
        .padding()
    }
}

