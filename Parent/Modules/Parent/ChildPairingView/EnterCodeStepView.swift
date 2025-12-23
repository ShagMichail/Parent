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
            
            Text("Введите уникальный код")
                .font(.system(size: 24, weight: .semibold, design: .rounded))
                .frame(maxWidth: .infinity, alignment: .center)

            OTPField(numberOfFields: 6, code: $invitationCode)
                        
            ContinueButton(
                model: ContinueButtonModel(
                    title: "или отсканировать код",
                    isEnabled: false,
                    action: {
                        print("Hey hey")
                    }
                )
            )
            .frame(height: 50)
            
            Spacer()
            
            NavigationLink(
                destination: EnterGenderStepView(invitationCode: invitationCode),
                isActive: $isNameStepActive
            ) { EmptyView() }
            
            ContinueButton(
                model: ContinueButtonModel(
                    title: "Продолжить",
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
    }
}

