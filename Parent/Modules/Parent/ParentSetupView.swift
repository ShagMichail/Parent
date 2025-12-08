////
////  ParentSetupView.swift
////  Parent
////
////  Created by Михаил Шаговитов on 13.11.2025.
////
//
//import SwiftUI
//
//struct ParentSetupView: View {
//    @EnvironmentObject var authManager: AuthenticationManager
//    
//    var body: some View {
//        VStack(spacing: 30) {
//            Image(systemName: "shield.parental")
//                .font(.system(size: 80))
//                .foregroundColor(.blue)
//            
//            Text("Настройка родительского контроля")
//                .font(.largeTitle)
//                .fontWeight(.bold)
//                .multilineTextAlignment(.center)
//            
//            Text("Нажмите кнопку ниже, чтобы выбрать детей из вашей семейной группы, для которых вы хотите установить ограничения.")
//                .multilineTextAlignment(.center)
//                .foregroundColor(.secondary)
//            
//            Button("Начать настройку") {
//                authManager.requestParentAuthorization()
//            }
//            .buttonStyle(.borderedProminent)
//            .controlSize(.large)
//        }
//        .padding(30)
//    }
//}
