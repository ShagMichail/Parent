//
//  AppBlockView.swift
//  Parent
//
//  Created by Michail Shagovitov on 19.12.2025.
//

import SwiftUI

struct AppBlockView: View {
    @Binding var showNavigationBar: Bool
    let child: Child?
    
    @StateObject private var viewModel = AppBlockViewModel()
    @State private var isPickerPresented = false
    @State private var showUnsavedChangesAlert = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            if viewModel.isLoadingInitialBlocks {
                Spacer()
                ProgressView("Loading locks...")
                    .frame(maxWidth: .infinity)
                Spacer()
            } else {
                VStack(spacing: 0) {
                    NavigationBar(
                        model: NavigationBarModel(
                            chevronBackward: true,
                            subTitle: String(localized: "Blocking apps"),
                            hasConfirm: viewModel.hasChanges,
                            onBackTap: {
                                handleBackButton()
                            },
                            onNotificationTap: {},
                            onConfirmTap: {
                                viewModel.saveBlocks()
                            }
                        )
                    )
                    ScrollView {
                        VStack(alignment: .leading) {
                            if viewModel.blocks.isEmpty {
                                Text("Click on 'Select Applications' to add restrictions.")
                                    .font(.custom("Inter-Regular", size: 14))
                                    .foregroundColor(.strokeTextField)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            } else {
                                ForEach($viewModel.blocks) { $block in
                                    AppBlockRow(block: $block)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 10)
                    }
                    .scrollIndicators(.hidden)
                    
                    VStack {
                        Button(action: {
                            isPickerPresented = true
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "plus.circle.fill")
                                    .resizable()
                                    .frame(width: 16, height: 16)
                                Text("Select Applications")
                                    .font(.custom("Inter-Regular", size: 16))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 20)
                            .padding(.horizontal, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 20).fill(.accent)
                            )
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .navigationBarHidden(true)
        .background(Color.roleBackground.ignoresSafeArea())
        .familyActivityPicker(
            isPresented: $isPickerPresented,
            selection: $viewModel.selection
        )
        .onAppear {
            viewModel.child = self.child
            viewModel.loadInitialBlocks()
        }
    
        .onChange(of: viewModel.selection) { _, _ in
            viewModel.syncBlocksWithSelection()
        }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text(viewModel.alertTitle),
                message: Text(viewModel.alertMessage),
                dismissButton: .default(Text("OK")) {
                    if case .success = viewModel.savingState {
                        // Тут можно, например, закрыть экран
                    }
                    viewModel.savingState = .idle
                }
            )
        }
        .alert("Unsaved changes", isPresented: $showUnsavedChangesAlert) {
            Button("Exit without saving", role: .destructive) {
                showNavigationBar.toggle()
                dismiss()
            }
            Button("Continue editing", role: .cancel) {
                
            }
        } message: {
            Text("You have unsaved changes. If you exit, they will be lost.")
        }
    }

    private func handleBackButton() {
        if viewModel.hasChanges {
            showUnsavedChangesAlert = true
        } else {
            showNavigationBar.toggle()
            dismiss()
        }
    }
}
