//
//  ErrorView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 04.12.2025.
//

import SwiftUI
 
struct ErrorView: View {
    let errorMessage: String
    let onRetry: () -> Void

    var body: some View {
        VStack(alignment: .center, spacing: 25) {
            Text("Ошибка создания приглашения")
                .font(.custom("Inter-SemiBold", size: 20))
                .frame(maxWidth: .infinity, alignment: .center)
            
            Text(errorMessage)
                .font(.custom("Inter-Regular", size: 16))
                .frame(maxWidth: .infinity, alignment: .center)
            
            Image(systemName: "exclamationmark.triangle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)

            Spacer()
            
            Button(action: onRetry) {
                ContinueButton(
                    model: ContinueButtonModel(
                        title: "Попробовать снова",
                        isEnabled: true,
                        action: {
                            
                        }
                    )
                )
                .frame(height: 50)
            }
        }
        .padding(.top, 80)
        .padding(.bottom, 92)
        .padding(.horizontal, 20)
        .background(Color.roleBackground.ignoresSafeArea())
        .ignoresSafeArea(.container, edges: .bottom)
    }
}
//
//#Preview {
//    ErrorView(errorMessage: "Что-то не работает", onRetry: {
//        
//    })
//}

