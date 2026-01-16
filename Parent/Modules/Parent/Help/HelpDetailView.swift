//
//  HelpDetailView.swift
//  Parent
//
//  Created by Michail Shagovitov on 16.01.2026.
//

import SwiftUI

struct HelpDetailView: View {
    let topic: HelpTopic
    let onDismiss: () -> Void
    
    var body: some View {
        
        VStack(spacing: 0) {
            NavigationBar(
                model: NavigationBarModel(
                    chevronBackward: true,
                    subTitle: topic.topicName,
                    onBackTap: {
                        onDismiss()
                    }
                )
            )
            
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    HStack {
                        Image(systemName: topic.iconName)
                            .font(.system(size: 48))
                            .foregroundColor(.accent)
                        Text(topic.topicOn)
                            .font(.custom("Inter-SemiBold", size: 20))
                            .foregroundColor(.blackText)
                        Spacer()
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Why is this necessary?")
                            .font(.custom("Inter-Medium", size: 18))
                            .foregroundColor(.blackText)
                        Text(topic.topicDescription)
                            .font(.custom("Inter-Regular", size: 16))
                            .foregroundColor(.strokeTextField)
                    }
                    
                    VStack(alignment: .leading, spacing: 20) {
                        Text("How to enable it on a child's device:")
                            .font(.custom("Inter-SemiBold", size: 20))
                            .foregroundColor(.blackText)
                        
                        steps(for: topic)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                }
                .padding()
            }
            .scrollIndicators(.hidden)
        }
        .navigationBarHidden(true)
        .background(Color.roleBackground.ignoresSafeArea())
    }
    
    @ViewBuilder
    private func steps(for topic: HelpTopic) -> some View {
        switch topic {
        case .notifications:
            InstructionRow(
                model: InstructionRowModel(
                    number: "1",
                    text: String(localized: "Open 'Settings' -> 'Applications'.")
                )
            )
            InstructionRow(
                model: InstructionRowModel(
                    number: "2",
                    text: String(localized: "Find our 'Parental Control' application in the list.")
                )
            )
            InstructionRow(
                model: InstructionRowModel(
                    number: "3",
                    text: String(localized: "In the 'Notifications' section, turn on 'Notification Tolerance'.")
                )
            )
        case .location:
            InstructionRow(
                model: InstructionRowModel(
                    number: "1",
                    text: String(localized: "Open 'Settings' -> 'Applications'.")
                )
            )
            InstructionRow(
                model: InstructionRowModel(
                    number: "2",
                    text: String(localized: "Find our 'Parental Control' application in the list.")
                )
            )
            InstructionRow(
                model: InstructionRowModel(
                    number: "3",
                    text: String(localized: "In the 'Location' section, allow access 'Always'.")
                )
            )
        case .keyboard:
            InstructionRow(
                model: InstructionRowModel(
                    number: "1",
                    text: String(localized: "Open 'Settings' -> 'Basic' -> 'Keyboard -> 'Keyboards'.")
                )
            )
            InstructionRow(
                model: InstructionRowModel(
                    number: "2",
                    text: String(localized: "Click on 'New Keyboards' and select 'Parental Control'.")
                )
            )
            InstructionRow(
                model: InstructionRowModel(
                    number: "3",
                    text: String(localized: "Click on the added keyboard and enable 'Allow Full Access'.")
                )
            )
            InstructionRow(
                model: InstructionRowModel(
                    number: "4",
                    text: String(localized: "For a complete analysis, it is necessary to remove all other keyboards.")
                )
            )
        }
    }
}
