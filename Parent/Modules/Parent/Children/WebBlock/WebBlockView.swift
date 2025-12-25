//
//  WebBlockView.swift
//  Parent
//
//  Created by Michail Shagovitov on 22.12.2025.
//

import SwiftUI

struct WebBlockView: View {
    @Binding var showNavigationBar: Bool
    let child: Child?
    
    @StateObject private var viewModel = WebBlockViewModel()
    @State private var newDomain: String = ""
    @State private var showUnsavedChangesAlert = false
    @Environment(\.dismiss) var dismiss
    
    @Namespace private var animationNamespace

    var body: some View {
        ZStack {
            // --- СЛОЙ 1: ОСНОВНОЙ КОНТЕНТ (с блюром) ---
            mainContent
                .blur(radius: viewModel.selectedBlockForActions != nil ? 5 : 0)
            
            // --- СЛОЙ 2: ОВЕРЛЕЙ С ДЕЙСТВИЯМИ (когда блок выбран) ---
            if let selectedBlock = viewModel.selectedBlockForActions {
                // Затемняющий фон
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring()) {
                            viewModel.selectedBlockForActions = nil
                        }
                    }
                    .transition(.opacity)
                
                // Карточка и кнопки
                VStack(spacing: 16) {
                    // "Вылетевшая" карточка
                    WebBlockCardView(block: selectedBlock)
                        .matchedGeometryEffect(id: selectedBlock.id, in: animationNamespace)
                        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
                    
                    // Кнопка "Удалить"
                    Button {
                        withAnimation {
                            viewModel.deleteBlock(selectedBlock)
                            viewModel.selectedBlockForActions = nil
                        }
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                            Text("Remove")
                        }
                        .font(.custom("Inter-Medium", size: 16))
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                    }
                    .padding(.horizontal, 40) // Делаем кнопку чуть уже
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .padding(.horizontal, 20)
                .zIndex(2)
            }
        }
        .navigationBarHidden(true)
        .background(Color.roleBackground.ignoresSafeArea())
        .onAppear {
            viewModel.child = self.child
            viewModel.loadInitialBlocks()
        }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text(viewModel.alertTitle),
                message: Text(viewModel.alertMessage),
                dismissButton: .default(Text("OK")) {
                    if case .success = viewModel.savingState {

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
    
    /// Основной контент вынесен в отдельную переменную
    private var mainContent: some View {
        VStack(spacing: 0) {
            NavigationBar(
                model: NavigationBarModel(
                    chevronBackward: true,
                    subTitle: String(localized: "Website blocking"),
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
            
            if viewModel.isLoadingInitialBlocks {
                Spacer()
                ProgressView("Loading...")
                    .frame(maxWidth: .infinity)
                Spacer()
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        if viewModel.blocks.isEmpty {
                            Text("Add a domain to block the site.")
                        } else {
                            ForEach(viewModel.blocks) { block in
                                // Логика для анимации
                                if viewModel.selectedBlockForActions?.id == block.id {
                                    // Оставляем "дырку", пока карточка "летает"
                                    Rectangle().fill(Color.clear).frame(height: 70)
                                } else {
                                    WebBlockCardView(block: block)
                                        .matchedGeometryEffect(id: block.id, in: animationNamespace)
                                        .onTapGesture {
                                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                                viewModel.selectedBlockForActions = block
                                            }
                                        }
                                }
                            }
                        }
                    }
                    .padding()
                }
                
                // Поле для ввода
                HStack {
                    TextField("example.com", text: $newDomain)
                        .keyboardType(.URL)
                        .disableAutocorrection(true)
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(.accent, lineWidth: 1)
                        )

                    Button(action: {
                        viewModel.addDomain(newDomain)
                        newDomain = "" // Очищаем поле
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .frame(width: 16, height: 16)
                            Text("Add a domain")
                                .font(.custom("Inter-Regular", size: 16))
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 12).fill(.accent)
                        )
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                    .disabled(newDomain.isEmpty)
                }
                .padding()
            }
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
