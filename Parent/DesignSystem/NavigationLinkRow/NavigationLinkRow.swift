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

struct NavigationLinkRow: View {
    let title: String
    var action: () -> Void = {}
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.blackText)
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
