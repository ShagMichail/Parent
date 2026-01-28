//
//  EnterGenderStepView.swift
//  Parent
//
//  Created by Michail Shagovitov on 22.12.2025.
//

import SwiftUI

struct EnterGenderStepView: View {

    let invitationCode: String
    
    @State private var selectedRole: UserRole? = nil
    @State private var isLoading = false
    @State private var isGenderStepActive = false
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 25) {
            Text("Choose the gender of the child")
                .font(.custom("Inter-Medium", size: 24))
            
            VStack(spacing: 20) {
                RoleCardView(
                    model: RoleCardViewModel(
                        title: String(localized: "Boy"),
                        imageName: "men",
                        isSelected: selectedRole == .men
                    )
                )
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedRole = .men
                    }
                }
                
                RoleCardView(
                    model: RoleCardViewModel(
                        title: String(localized: "Girl"),
                        imageName: "girl",
                        isSelected: selectedRole == .girl
                    )
                )
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedRole = .girl
                    }
                }
            }
            
            Spacer()
            
            if isLoading {
                ProgressView()
                    .frame(height: 50)
            } else {
                ContinueButton(
                    model: ContinueButtonModel(
                        title: String(localized: "Continue"),
                        isEnabled: selectedRole != nil,
                        fullWidth: true,
                        action: {
                            isGenderStepActive = true
                        }
                    )
                )
                .frame(height: 50)
            }
        }
        .padding(.bottom, 92)
        .padding(.top, 80)
        .padding(.horizontal, 20)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .ignoresSafeArea(.container, edges: .bottom)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .navigationBarBackButtonHidden(true)
        .toolbarRole(.editor)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.backward")
                            .font(.headline)
                            .foregroundColor(.accent)
                    }.frame(height: 50)
                }
            }
        }
        .navigationDestination(isPresented: $isGenderStepActive, destination: { EnterNameStepView(invitationCode: invitationCode, childGender: selectedRole?.rawValue ?? "unknown")})
    }
}
