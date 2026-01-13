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
            Text("Account is ready")
                .font(.custom("Inter-SemiBold", size: 24))
                .frame(maxWidth: .infinity, alignment: .center)
            
            Text("Complete setup on your device")
                .font(.custom("Inter-Regular", size: 16))
                .frame(maxWidth: .infinity, alignment: .center)
            
            Spacer()
            
            Image("child-completed")
                .aspectRatio(contentMode: .fit)
            
            Spacer()
            
            ContinueButton(
                model: ContinueButtonModel(
                    title: String(localized: "Continue"),
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
        .background(Color.roleBackground.ignoresSafeArea())
        .ignoresSafeArea(.container, edges: .bottom)
        .navigationBarBackButtonHidden(true)
    }
    
    private func acceptInvitation() async {
//        let notificationsGranted = await stateManager.requestNotificationPermission()
//        
//        print("🔔 Статус разрешения уведомлений, полученный от менеджера: \(notificationsGranted)")
//        
        await MainActor.run {
            stateManager.didCompletePairing()
        }
    }
}

//#Preview {
//    ChildCompletedView()
//}
