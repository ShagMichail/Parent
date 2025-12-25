//
//  WaitingForChildView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 04.12.2025.
//

import SwiftUI

struct WaitingForChildView: View {
    let invitationCode: String
    
    var body: some View {
        VStack {
            
            VStack(alignment: .leading, spacing: 25) {
                Text("Login using code")
                    .font(.custom("Inter-SemiBold", size: 24))
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Text("To start monitoring and help your child stay safe, connect their device:")
                    .font(.custom("Inter-Regular", size: 16))
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
                
                InstructionRow(
                    model: InstructionRowModel(
                        number: "1",
                        text: String(localized: "Download the application to your child’s phone.(Can be installed from the App Store or Google Play.)")
                    )
                )
                InstructionRow(
                    model: InstructionRowModel(
                        number: "2",
                        text: String(localized: "Open the application and select the “Child” role»")
                    )
                )
                InstructionRow(
                    model: InstructionRowModel(
                        number: "3",
                        text: String(localized: "Enter the unique connection code that is displayed")
                    )
                )
                InstructionRow(
                    model: InstructionRowModel(
                        number: "4",
                        text: String(localized: "After entering the code, the device will automatically connect")
                    )
                )
            }
            
            VStack {
                ZStack(alignment: .center) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.accent)
                    
                    Text(invitationCode)
                        .font(.custom("Inter-Medium", size: 36))
                        .kerning(4)
                        .foregroundColor(.white)
                }
                .frame(maxHeight: 75)
                .padding(.horizontal, 60)
                
                Spacer()
                
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
            }
            .padding(.top, 40)
            
        }
        .padding(.top, 80)
        .padding(.bottom, 92)
        .padding(.horizontal, 20)
        .ignoresSafeArea(.container, edges: .bottom)
    }
}
