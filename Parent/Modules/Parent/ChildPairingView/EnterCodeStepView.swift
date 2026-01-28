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
    @State private var hasError = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(alignment: .center, spacing: 25) {
            
            VStack(spacing: 10) {
                Text("Enter a unique code")
                    .font(.custom("Inter-SemiBold", size: 24))
                    .frame(maxWidth: .infinity, alignment: .center)
                
                OTPField(isError: hasError, numberOfFields: 6, code: $invitationCode)
                
                if hasError {
                    Text(errorMessage)
                        .font(.custom("Inter-Regular", size: 14))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .foregroundStyle(.errorMessage)
                }
            }
            
            ContinueButton(
                model: ContinueButtonModel(
                    title: String(localized: "or scan the code"),
                    isEnabled: true,
                    fullWidth: true,
                    action: {
                        showScanner = true
                    }
                )
            )
            .frame(height: 50)
            
            Spacer()
            
            if isLoading {
                ProgressView()
                    .frame(height: 50)
            } else {
                ContinueButton(
                    model: ContinueButtonModel(
                        title: String(localized: "Continue"),
                        isEnabled: invitationCode.count == 6,
                        fullWidth: true,
                        action: {
                            Task {
                                await verifyCode(scannedCode: invitationCode)
                            }
                        }
                    )
                )
                .frame(height: 50)
            }
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
        .onChange(of: invitationCode) { _, _ in
            if hasError {
                hasError = false
                errorMessage = ""
            }
        }
    }
    
    private var scannerSheetView: some View {
        ZStack(alignment: .topTrailing) {
            QRCodeScannerView { code in
                Task {
                    await verifyCode(scannedCode: code)
                }
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
    
    private func verifyCode(scannedCode: String) async {
        isLoading = true
        hasError = false
        errorMessage = ""
        
        self.invitationCode = scannedCode
        
        let status = await CloudKitManager.shared.checkInvitationStatus(withCode: scannedCode)
        
        switch status {
        case .valid:
            print("✅ Код \(scannedCode) валиден.")
            if showScanner { showScanner = false }
            isNameStepActive = true
            
        case .notFound:
            print("❌ Код \(scannedCode) не найден.")
            hasError = true
            errorMessage = String(localized: "Incorrect code! Check it again")
            if showScanner { showScanner = false }
            
        case .expired:
            print("⏰ Код \(scannedCode) истек.")
            hasError = true
            errorMessage = String(localized: "Ask the parent to update the code")
            if showScanner { showScanner = false }
        }
        
        isLoading = false
    }
}
