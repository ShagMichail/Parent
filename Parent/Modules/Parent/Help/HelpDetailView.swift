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
                VStack {
                    HStack(spacing: 20) {
                        Image(topic.iconName)
                            .font(.system(size: 48))
                            .foregroundColor(.accent)
                        Text(topic.topicOn)
                            .font(.custom("Inter-SemiBold", size: 20))
                            .foregroundColor(.blackText)
                        Spacer()
                    }
                    .padding(.bottom, 30)
                    
                    VStack(spacing: 5) {
                        Text("Why is this necessary?")
                            .font(.custom("Inter-Medium", size: 16))
                            .foregroundColor(.blackText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(topic.topicDescription)
                            .font(.custom("Inter-Regular", size: 16))
                            .foregroundColor(.strokeTextField)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.bottom, 50)
                    
                    VStack(alignment: .leading, spacing: 30) {
                        Text("How to enable it on a child's device:")
                            .font(.custom("Inter-SemiBold", size: 20))
                            .foregroundColor(.blackText)
                        
                        steps(for: topic)
                    }
                }
                .padding(.horizontal, 20)
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
                    text: String(localized: "Open 'Settings' -> 'Applications'")
                )
            )
            InstructionRow(
                model: InstructionRowModel(
                    number: "2",
                    text: String(localized: "Find our 'Parental Control' application in the list")
                )
            )
            InstructionRow(
                model: InstructionRowModel(
                    number: "3",
                    text: String(localized: "In the 'Notifications' section, turn on 'Notification Tolerance'")
                )
            )
        case .location:
            InstructionRow(
                model: InstructionRowModel(
                    number: "1",
                    text: String(localized: "Open 'Settings' -> 'Applications'")
                )
            )
            InstructionRow(
                model: InstructionRowModel(
                    number: "2",
                    text: String(localized: "Find our 'Parental Control' application in the list")
                )
            )
            InstructionRow(
                model: InstructionRowModel(
                    number: "3",
                    text: String(localized: "In the 'Location' section, allow access 'Always'")
                )
            )
        case .keyboard:
            InstructionRow(
                model: InstructionRowModel(
                    number: "1",
                    text: String(localized: "Open 'Settings' -> 'Basic' -> 'Keyboard -> 'Keyboards'")
                )
            )
            InstructionRow(
                model: InstructionRowModel(
                    number: "2",
                    text: String(localized: "Click on 'New Keyboards' and select 'Parental Control'")
                )
            )
            InstructionRow(
                model: InstructionRowModel(
                    number: "3",
                    text: String(localized: "Click on the added keyboard and enable 'Allow Full Access'")
                )
            )
            InstructionRow(
                model: InstructionRowModel(
                    number: "4",
                    text: String(localized: "For a complete analysis, it is necessary to remove all other keyboards")
                )
            )
        }
    }
}
