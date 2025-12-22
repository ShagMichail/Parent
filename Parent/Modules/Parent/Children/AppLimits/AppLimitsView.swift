//
//  AppLimitsView.swift
//  Parent
//
//  Created by Michail Shagovitov on 19.12.2025.
//

import SwiftUI

struct AppLimitsView: View {
    @Binding var showNavigationBar: Bool
    let child: Child?
    
    @StateObject private var viewModel = AppLimitsViewModel()
    @State private var isPickerPresented = false
    @State private var showUnsavedChangesAlert = false
    @Environment(\.dismiss) var dismiss
    
    // Предопределенные варианты времени для Picker
    let timeOptions: [TimeInterval] = [900, 1800, 3600, 7200, 10800] // 15м, 30м, 1ч, 2ч, 3ч

    var body: some View {
        VStack {
            if viewModel.isLoadingInitialLimits {
                Spacer()
                ProgressView("Загрузка лимитов...")
                    .frame(maxWidth: .infinity)
                Spacer()
            } else {
                VStack(spacing: 0) {
                    NavigationBar(
                        model: NavigationBarModel(
                            chevronBackward: true,
                            subTitle: "Лимиты",
                            hasConfirm: viewModel.hasChanges,
                            onBackTap: {
                                handleBackButton()
                            },
                            onNotificationTap: {},
                            onConfirmTap: {
                                viewModel.saveLimits()
                            }
                        )
                    )
                    ScrollView {
                        VStack(alignment: .leading) {
                            if viewModel.limits.isEmpty {
                                Text("Нажмите 'Выбрать приложения', чтобы добавить ограничения.")
                                    .font(.system(size: 14, weight: .regular, design: .rounded))
                                    .foregroundColor(.strokeTextField)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            } else {
                                ForEach($viewModel.limits) { $limit in
                                    AppLimitRow(limit: $limit)
                                }
                                .onDelete(perform: viewModel.deleteLimit)
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
                                Text("Выбрать приложения")
                                    .font(.system(size: 16, weight: .regular))
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
        .background(Color.roleBackround.ignoresSafeArea())
        .familyActivityPicker(
            isPresented: $isPickerPresented,
            selection: $viewModel.selection
        )
        .onAppear {
            viewModel.child = self.child
            viewModel.loadInitialLimits()
        }
    
        .onChange(of: viewModel.selection) { _, _ in
            viewModel.syncLimitsWithSelection()
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
        .alert("Несохраненные изменения", isPresented: $showUnsavedChangesAlert) {
            Button("Выйти без сохранения", role: .destructive) {
                showNavigationBar.toggle()
                dismiss()
            }
            Button("Продолжить редактирование", role: .cancel) {
                
            }
        } message: {
            Text("У вас есть несохраненные изменения. Если вы выйдете, они будут потеряны.")
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
