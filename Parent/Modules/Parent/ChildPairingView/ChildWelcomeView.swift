//
//  ChildWelcomeView.swift
//  Parent
//
//  Created by Michail Shagovitov on 15.12.2025.
//

import SwiftUI

//struct ChildWelcomeView: View {
//    @EnvironmentObject var stateManager: AppStateManager
//
//    var body: some View {
//        VStack(spacing: 30) {
//            Spacer()
//            Text("Добро пожаловать!")
//                .font(.largeTitle.bold())
//            
//            Image(systemName: "shield.lefthalf.filled") // Замените на свою картинку
//                .font(.system(size: 100))
//                .foregroundColor(.accentColor)
//                
//            Text("Это приложение поможет родителям\nзаботиться о вашей безопасности в сети.")
//                .font(.headline)
//                .multilineTextAlignment(.center)
//                .padding(.horizontal)
//            
//            Spacer()
//            
//            ContinueButton(
//                model: ContinueButtonModel(
//                    title: "Продолжить",
//                    isEnabled: true,
//                    action: {
//                        stateManager.childDidAcknowledgeWelcome()
//                    }
//                )
//            )
//            .frame(height: 50)
//            .padding()
//        }
//    }
//}
