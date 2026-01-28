//
//  WaitingForChildView.swift
//  Parent
//
//  Created by Михаил Шаговитов on 04.12.2025.
//

import SwiftUI

struct WaitingForChildView: View {
    let invitationCode: String?
    
    @State private var showQRSheet = false
    @State private var qrCodeImage: UIImage?
    
    let onUpdateCode: () -> Void
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                
                ContinueButton(
                    model: ContinueButtonModel(
                        title: String(localized: "Update the code"),
                        isEnabled: invitationCode != nil,
                        isBackground: false,
                        textColor: .accent,
                        action: {
                            onUpdateCode()
                        }
                    )
                )
                .frame(height: 50)
            }
            
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
                VStack {
                    ZStack(alignment: .center) {
                        // 2. Логика отображения
                        if let code = invitationCode, code == "ERROR" {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.errorMessage)
                            
                            VStack(spacing: 10) {
                                Text("Couldn't load the code")
                                    .font(.custom("Inter-Medium", size: 16))
                                    .foregroundColor(.white)
                                Text("Try updating it")
                                    .font(.custom("Inter-Medium", size: 16))
                                    .foregroundColor(.white)
                            }
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, alignment: .center)
                            
                        } else if let code = invitationCode {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.accent)
                            
                            Text(code)
                                .font(.custom("Inter-Medium", size: 36))
                                .kerning(4)
                                .foregroundColor(.white)
                                .transition(.opacity.combined(with: .scale))
                        } else {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.accent)
                            
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(1.5)
                                .transition(.opacity)
                        }
                    }
                    .frame(maxHeight: 75)
                    .padding(.horizontal, 60)
                    .animation(.easeInOut, value: invitationCode)
                    
                    
                    Spacer()
                    
                    ContinueButton(
                        model: ContinueButtonModel(
                            title: String(localized: "or scan the code"),
                            isEnabled: (invitationCode != nil && invitationCode != "ERROR"),
                            fullWidth: true,
                            action: {
                                if let code = invitationCode {
                                    if qrCodeImage == nil {
                                        qrCodeImage = QRCodeGenerator.generate(from: code)
                                    }
                                    showQRSheet = true
                                }
                            }
                        )
                    )
                    .frame(height: 50)
                }
            }
            .padding(.top, 40)
        }
        .padding(.top, 10)
        .padding(.bottom, 92)
        .padding(.horizontal, 20)
        .ignoresSafeArea(.container, edges: .bottom)
        .sheet(isPresented: $showQRSheet) {
            if let code = invitationCode {
                QRCodeSheetView(qrCodeImage: $qrCodeImage, invitationCode: code)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
        }
        .onChange(of: invitationCode) { _, newCode in
            if let newCode = newCode {
                qrCodeImage = QRCodeGenerator.generate(from: newCode)
            }
        }
    }
}
