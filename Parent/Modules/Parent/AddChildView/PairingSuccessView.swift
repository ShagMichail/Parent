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
            Text("Child's account is connected")
                .font(.custom("Inter-SemiBold", size: 24))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal, 20)
                .padding(.bottom, 25)
            
            Text("Do not forget to give all necessary permissions on the child's device for the correct operation of parental controls.")
                .font(.custom("Inter-Regular", size: 16))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal, 20)

            Spacer()
            
            Image("parent-completed")
                .aspectRatio(contentMode: .fit)
            
            Spacer()
            
            
            ContinueButton(
                model: ContinueButtonModel(
                    title: String(localized: "Begin"),
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
        .background(Color.roleBackground.ignoresSafeArea())
        .ignoresSafeArea(.container, edges: .bottom)
        .navigationBarBackButtonHidden(true)
    }
    
    private func parentScreen() async {
        stateManager.didAddChild(newChild)
    }
}

//#Preview {
//    PairingSuccessView(newChild: Child(id: UUID(), name: "Ivan", recordID: "", gender: "men"))
//}
