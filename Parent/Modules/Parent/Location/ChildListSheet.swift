//
//  ChildListSheet.swift
//  Parent
//
//  Created by Michail Shagovitov on 16.12.2025.
//

import SwiftUI

struct ChildListSheet: View {
    @Binding var isExpanded: Bool
    @ObservedObject var viewModel: LocationViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Все устройства")
                    .font(.system(size: 24, weight: .medium, design: .rounded))
                    .foregroundStyle(.blackText)
                Spacer()
                Button(action: {
                    withAnimation(.spring()) {
                        isExpanded.toggle()
                    }
                }) {
                    Image(systemName: "chevron.up")
                        .font(.headline.weight(.semibold))
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .foregroundStyle(.blackText)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            
            if isExpanded {
                VStack(spacing: 20) {
                    ForEach(viewModel.children) { child in
                        ChildRowView(
                            model: ChildRowViewModel(
                                childName: child.name,
                                childAddress: viewModel.getStreetName(for: child.recordID),
                                childBatteryLevel: viewModel.getBatteryText(for: child.recordID),
                                childBatteryColor: viewModel.getBatteryColor(for: child.recordID)
                            )
                        )
                        .onTapGesture {
                            withAnimation {
                                viewModel.selectedChild = child
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedCorner(radius: 30, corners: [.topLeft, .topRight]))
        .shadow(color: .black.opacity(0.1), radius: 10, y: -5)
    }
}

