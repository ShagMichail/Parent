//
//  NotificationView.swift
//  Parent
//
//  Created by Michail Shagovitov on 14.01.2026.
//

import SwiftUI
import FamilyControls
import DeviceActivity

struct NotificationView: View {
    @State private var reportRefreshID = UUID()
    @Environment(\.dismiss) var dismiss
    @Binding var showNavigationBar: Bool
    @EnvironmentObject var viewModel: NotificationViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                NavigationBar(
                    model: NavigationBarModel(
                        chevronBackward: true,
                        subTitle: String(localized: "Notifications"),
                        onBackTap: {
                            dismiss()
                            showNavigationBar.toggle()
                        }
                    )
                )
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        ChildSelectorView(
                            children: $viewModel.children,
                            selectedChild: $viewModel.selectedChild,
                            showBatteryLevel: false,
                            canChildAdd: false,
                            onAddChild: {
                            }
                        )
                        .padding(.bottom, 10)
                        
                        if viewModel.selectedChild != nil {
                            NotificationDetailView()
                                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                                .id(reportRefreshID)
                        } else {
                            VStack(spacing: 10) {
                                Image(systemName: "person.3.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.gray)
                                Text("Add a child")
                                    .font(.headline)
                                Text("Click on the '+' to add the first child.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                        }
                    }
                }
                .refreshable {
                    reportRefreshID = UUID()
                    viewModel.refresh()
                }
                .scrollIndicators(.hidden)
            }
            .navigationBarHidden(true)
            .background(Color.roleBackground.ignoresSafeArea())
        }
        .id(viewModel.selectedChild?.id)
    }
}
