//
//  ReportLoadingView.swift
//  Parent
//
//  Created by Michail Shagovitov on 18.12.2025.
//

import SwiftUI

struct ReportLoadingView: View {
    @State private var isAnimating = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                VStack(alignment: .leading, spacing: 12) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 150, height: 24)
                    
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 150)
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 200, height: 24)
                    
                    VStack {
                        ForEach(0..<4) { _ in
                            HStack {
                                Circle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: 40, height: 40)
                                
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 18)
                                
                                Spacer()
                                
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: 60, height: 18)
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(20)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
        }
        .background(Color.roleBackground)
        .opacity(isAnimating ? 0.7 : 1.0)
        .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isAnimating)
        .onAppear {
            isAnimating = true
        }
        .disabled(true)
    }
}
