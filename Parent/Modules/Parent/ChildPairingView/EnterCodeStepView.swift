//
//  EnterCodeStepView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 04.12.2025.
//

import SwiftUI

struct EnterCodeStepView: View {
    @State private var invitationCode = ""
    @State private var isLoading = false
    
    @State private var isNameStepActive = false

    var body: some View {
        VStack(alignment: .leading, spacing: 25) {
            
            Text("Enter a unique code")
                .font(.custom("Inter-SemiBold", size: 24))
                .frame(maxWidth: .infinity, alignment: .center)

            OTPField(numberOfFields: 6, code: $invitationCode)
                        
            ContinueButton(
                model: ContinueButtonModel(
                    title: String(localized: "or scan the code"),
                    isEnabled: false,
                    action: {
                        print("Hey hey")
                    }
                )
            )
            .frame(height: 50)
            
            Spacer()
            
            ContinueButton(
                model: ContinueButtonModel(
                    title: String(localized: "Continue"),
                    isEnabled: invitationCode.count == 6,
                    action: {
                        isNameStepActive = true
                    }
                )
            )
            .frame(height: 50)
        }
        .padding(.top, 80)
        .padding(.bottom, 92)
        .padding(.horizontal, 20)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .ignoresSafeArea(.container, edges: .bottom)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .navigationDestination(isPresented: $isNameStepActive, destination: { EnterGenderStepView(invitationCode: invitationCode)})
    }
}

