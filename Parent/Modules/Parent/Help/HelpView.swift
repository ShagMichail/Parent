//
//  HelpView.swift
//  Parent
//
//  Created by Michail Shagovitov on 16.01.2026.
//

import SwiftUI

struct HelpView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var showNavigationBar: Bool
    
    @State private var navigateToNotifications = false
    @State private var navigateToLocation = false
    @State private var navigateToKeyboard = false
    
    var body: some View {
        VStack(spacing: 0) {
            NavigationBar(
                model: NavigationBarModel(
                    chevronBackward: true,
                    subTitle: String(localized: "Any questions?"),
                    onBackTap: {
                        dismiss()
                        showNavigationBar.toggle()
                    }
                )
            )
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Necessary settings on the child's device")
                    .font(.custom("Inter-Regular", size: 18))
                    .foregroundColor(.blackText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(spacing: 0) {
                    NavigationLinkRow(
                        model: NavigationLinkRowModel(
                            icon: "bell.badge.fill",
                            hasIcon: true,
                            title: String(localized: "Notifications"),
                            action: {
                                navigateToNotifications = true
                            }
                        )
                    )
                    Divider().padding(.horizontal, 10)
                    NavigationLinkRow(
                        model: NavigationLinkRowModel(
                            icon: "location.fill",
                            hasIcon: true,
                            title: String(localized: "Location"),
                            action: {
                                navigateToLocation = true
                            }
                        )
                    )
                    Divider().padding(.horizontal, 10)
                    NavigationLinkRow(
                        model: NavigationLinkRowModel(
                            icon: "keyboard.fill",
                            hasIcon: true,
                            title: String(localized: "Keyboard"),
                            action: {
                                navigateToKeyboard = true
                            }
                        )
                    )
                }
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                )
                .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
                
                Spacer()
            }
            .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationBarHidden(true)
        .background(Color.roleBackground.ignoresSafeArea())
        .navigationDestination(
            isPresented: $navigateToNotifications,
            destination: {
                HelpDetailView(
                    topic: .notifications,
                    onDismiss: {
                        navigateToNotifications = false
                    })
            })
        .navigationDestination(
            isPresented: $navigateToLocation,
            destination: {
                HelpDetailView(
                    topic: .location,
                    onDismiss: {
                        navigateToLocation = false
                    }
                )
            })
        .navigationDestination(
            isPresented: $navigateToKeyboard,
            destination: {
                HelpDetailView(
                    topic: .keyboard,
                    onDismiss: {
                        navigateToKeyboard = false
                    }
                )
            })
    }
}
