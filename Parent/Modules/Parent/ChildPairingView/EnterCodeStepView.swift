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
    @State private var showScanner = false

    var body: some View {
        VStack(alignment: .leading, spacing: 25) {
            
            Text("Enter a unique code")
                .font(.custom("Inter-SemiBold", size: 24))
                .frame(maxWidth: .infinity, alignment: .center)

            OTPField(numberOfFields: 6, code: $invitationCode)
                        
            ContinueButton(
                model: ContinueButtonModel(
                    title: String(localized: "or scan the code"),
                    isEnabled: true,
                    action: {
                        showScanner = true
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
        .sheet(isPresented: $showScanner) {
            scannerSheetView
        }
    }
    
    private var scannerSheetView: some View {
        ZStack(alignment: .topTrailing) {
            QRCodeScannerView { code in
                self.invitationCode = code
                self.showScanner = false
                self.isNameStepActive = true
            }
            .ignoresSafeArea()
            
            Button(action: {
                showScanner = false
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .background(Color.black.opacity(0.5).clipShape(Circle()))
            }
            .padding()
        }
    }
}

