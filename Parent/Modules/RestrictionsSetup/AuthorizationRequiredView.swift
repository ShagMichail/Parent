//
//  AuthorizationRequiredView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 11.11.2025.
//

//import SwiftUI
//
//struct AuthorizationRequiredView: View {
//    var body: some View {
//        VStack(spacing: 20) {
//            Image(systemName: "lock.shield")
//                .font(.system(size: 50))
//                .foregroundColor(.orange)
//            
//            Text("Требуется разрешение")
//                .font(.title2)
//                .fontWeight(.bold)
//            
//            Text("Для выбора приложений необходимо предоставить доступ к данным об использовании приложений")
//                .multilineTextAlignment(.center)
//                .foregroundColor(.secondary)
//                .padding(.horizontal)
//            
//            Button("Предоставить доступ") {
//                if let url = URL(string: UIApplication.openSettingsURLString) {
//                    UIApplication.shared.open(url)
//                }
//            }
//            .buttonStyle(.borderedProminent)
//        }
//        .padding()
//    }
//}
