//
//  OnboardingPageView.swift
//  Parent
//
//  Created by Michail Shagovitov on 13.01.2026.
//

import SwiftUI

struct OnboardingPageView: View {
    let imageName: String
    let title: String
    let description: String
    
    @Binding var isRequesting: Bool
    
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 250, height: 250)
            
            VStack(spacing: 15) {
                Text(title)
                    .font(.custom("Inter-SemiBold", size: 28))
                    .foregroundColor(.blackText)
                    .multilineTextAlignment(.center)
                
                Text(description)
                    .font(.custom("Inter-Regular", size: 16))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.blackText)
            }
            
            Spacer()

            if isRequesting {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: 50)
            } else {
                ContinueButton(
                    model: ContinueButtonModel(
                        title: String(localized: "Continue"),
                        isEnabled: true,
                        action: {
                            action()
                        }
                    )
                )
                .frame(height: 50)
            }
        }
        .padding(.horizontal, 20)
    }
}

