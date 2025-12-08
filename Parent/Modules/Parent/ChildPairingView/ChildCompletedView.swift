//
//  ChildCompletedView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 04.12.2025.
//

import SwiftUI

struct ChildCompletedView: View {
    @EnvironmentObject var stateManager: AppStateManager
    
    var body: some View {
        VStack(alignment: .center, spacing: 25) {
            Text("Аккаунт готов")
                .font(.system(size: 24, weight: .semibold, design: .rounded))
                .frame(maxWidth: .infinity, alignment: .center)
            
            Text("Завершите настройку на вашем устройстве")
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .frame(maxWidth: .infinity, alignment: .center)
            
            Image("child-completed")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(RoundedCorner(radius: 1000, corners: .allCorners))
            
            ContinueButton(
                model: ContinueButtonModel(
                    title: "Продолжить",
                    isEnabled: true,
                    action: {
                        Task {
                            await acceptInvitation()
                        }
                    }
                )
            )
            .frame(height: 50)
        }
        .padding(.top, 80)
        .padding(.bottom, 92)
        .padding(.horizontal, 20)
        .background(Color.roleBackround.ignoresSafeArea())
        .ignoresSafeArea(.container, edges: .bottom)
        .navigationBarBackButtonHidden(true)
    }
    
    private func acceptInvitation() async {
        stateManager.didCompletePairing()
    }
}
//
//#Preview {
//    ChildCompletedView()
//}
