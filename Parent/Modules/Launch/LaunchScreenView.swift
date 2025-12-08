//
//  LaunchScreenView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 11.11.2025.
//

import SwiftUI

struct LaunchScreenView: View {
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            Circle()
                .fill(Color.blue.opacity(0.1))
                .frame(width: 300)
                .offset(x: -150, y: -300)
            
            Circle()
                .fill(Color.purple.opacity(0.1))
                .frame(width: 200)
                .offset(x: 150, y: 300)
            
            VStack(spacing: 30) {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "lock.shield")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                }
                
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.5)
                    
                    Text("Загрузка...")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
            }
        }
    }
}
