//
//  PairingSuccessView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 04.12.2025.
//

import SwiftUI

struct PairingSuccessView: View {
    @EnvironmentObject var stateManager: AppStateManager
    let newChild: Child
    
    var body: some View {
        VStack {
            Text("Аккаунт ребёнка соединён")
                .font(.system(size: 24, weight: .semibold, design: .rounded))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal, 20)

            Spacer()
            
            HStack {
                Image("conected-left")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedCorner(radius: 200, corners: [.topRight, .bottomRight]))
                
                Spacer()
                
                Image("conected-right")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(x: -1, y: 1)
                    .clipShape(RoundedCorner(radius: 200, corners: [.topLeft, .bottomLeft]))
            }
            
            Spacer()
            
            ContinueButton(
                model: ContinueButtonModel(
                    title: "Продолжить",
                    isEnabled: true,
                    action: {
                        Task {
                            await parentScreen()
                        }
                    }
                )
            )
            .frame(height: 50)
            .padding(.horizontal, 20)
        }
        .padding(.top, 80)
        .padding(.bottom, 92)
        .background(Color.roleBackround.ignoresSafeArea())
        .ignoresSafeArea(.container, edges: .bottom)
        .navigationBarBackButtonHidden(true)
}

    private func parentScreen() async {
        stateManager.didAddChild(newChild)
    }
}

//#Preview {
//    PairingSuccessView(childName: "Иван", onContinue: {
//        
//    })
//}

