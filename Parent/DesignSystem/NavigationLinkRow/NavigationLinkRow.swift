//
//  NavigationLinkRow.swift
//  Parent
//
//  Created by Michail Shagovitov on 11.12.2025.
//

import SwiftUI

enum NavigationDestination: Hashable {
    case appsActivity(childName: String)
    case visitedWebsites(childName: String)
}

struct NavigationLinkRowModel {
    let icon: String?
    let hasIcon: Bool?
    let title: String
    let action: () -> Void
    
    init(
        icon: String? = nil,
        hasIcon: Bool? = nil,
        title: String,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.hasIcon = hasIcon
        self.title = title
        self.action = action
    }
    
    
}

struct NavigationLinkRow: View {
    let model: NavigationLinkRowModel
    
    var body: some View {
        Button(action: model.action) {
            HStack {
                HStack(spacing: 10) {
                    if model.hasIcon ?? false {
                        Image(model.icon ?? "")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                            .foregroundStyle(.accent)
                    }
                    
                    Text(model.title)
                        .font(.custom("Inter-Regular", size: 16))
                        .foregroundColor(.blackText)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 10)
        }
    }
}
