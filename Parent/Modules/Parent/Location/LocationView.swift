//
//  LocationView.swift
//  Parent
//
//  Created by Michail Shagovitov on 15.12.2025.
//

import SwiftUI
import MapKit

struct LocationView: View {
    @StateObject private var viewModel: LocationViewModel
    
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var isListExpanded: Bool = false
    @State private var isChangingCameraProgrammatically = false
    @State private var isFirstUseMapCameraChange = false
    @State private var isFirstUseCamera = true
    
    init(stateManager: AppStateManager, cloudKitManager: CloudKitManager) {
        _viewModel = StateObject(wrappedValue: LocationViewModel(
            stateManager: stateManager,
            cloudKitManager: cloudKitManager
        ))
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Карта
                Map(position: $cameraPosition) {
                    ForEach(viewModel.children) { child in
                        if let coordinate = viewModel.childCoordinates[child.recordID] {
                            Annotation("", coordinate: coordinate) {
                                PinContentView(
                                    child: child,
                                    isSelected: child.recordID == viewModel.selectedChild?.recordID,
                                    onTap: {
                                        withAnimation {
                                            viewModel.selectedChild = child
                                        }
                                    }
                                )
                            }
                        }
                    }
                }
                .mapStyle(.standard(elevation: .flat))
                .ignoresSafeArea()
                .onMapCameraChange(frequency: .onEnd) { context in
                    // КОСТЫЛЬ!!! - сделано для быстроты - ИСПРАВИТЬ
                    if isChangingCameraProgrammatically && isFirstUseMapCameraChange {
                        isFirstUseMapCameraChange = false
                        return
                    } else if isChangingCameraProgrammatically {
                        isChangingCameraProgrammatically = false
                        return
                    }
                    if viewModel.selectedChild != nil {
                        withAnimation(.spring()) {
                            viewModel.selectedChild = nil
                        }
                    }
                }
                
                // Верхние кнопки
                VStack {
                    HStack {
                        Spacer()
                        VStack {
                            FloatingActionButton(iconName: "notification") {
                                print("🔔 Кнопка 'Уведомления' нажата")
                                // TODO: Добавьте здесь логику для перехода на экран уведомлений
                            }
                            Spacer()
                            FloatingActionButton(iconName: "current-location") {
                                print("🎯 Кнопка 'Мое местоположение' нажата")
                                // TODO: Добавьте здесь логику для центрирования карты на местоположении родителя
                            }
                            Spacer()
                        }
                    }
                    .padding(.trailing, 20)
                    .padding(.top, 10)
                    Spacer()
                }
                
                // Список детей (поверх карты)
                VStack(spacing: 0) {
                    Spacer()
                    
                    // ✅ ИЗМЕНЕНИЕ: Инфо-карточка появляется здесь
                    if let selectedChild = viewModel.selectedChild {
                        let isPingingBinding = Binding<Bool>(
                            get: { viewModel.isPinging[selectedChild.recordID, default: false] },
                            set: { _ in } // Нам не нужен set, View не меняет это состояние
                        )
                        
                        
                        ChildInfoCardView(
                            isPinging: isPingingBinding,
                            child: selectedChild,
                            address: viewModel.getStreetName(for: selectedChild.recordID),
                            onRefresh: {
                                viewModel.requestLocationUpdateForSelectedChild()
                            }
                        )
                        .padding(.bottom, 10)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    
                    
                    ChildListSheet(
                        isExpanded: $isListExpanded,
                        viewModel: viewModel
                    )
                }
                
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .progressViewStyle(.circular)
                }
            }
            .ignoresSafeArea(.keyboard)
        }
        .onAppear {
            viewModel.fetchAllStatuses()
        }
        .onChange(of: viewModel.selectedChild) { _, newChild in
            if newChild != nil {
                updateCameraPosition()
            }
        }
    }
    
    private func updateCameraPosition() {
        guard let selectedChild = viewModel.selectedChild else { return }
        guard let coordinate = viewModel.childCoordinates[selectedChild.recordID],
              CLLocationCoordinate2DIsValid(coordinate) else {
            return
        }
        isChangingCameraProgrammatically = true
        if isFirstUseCamera {
            isFirstUseCamera = false
            isFirstUseMapCameraChange = true
        }
        withAnimation(.easeInOut(duration: 0.5)) {
            cameraPosition = .camera(
                MapCamera(centerCoordinate: coordinate, distance: 3000)
            )
        }
    }
}

struct FloatingActionButton: View {
    let iconName: String
    let action: () -> Void // Замыкание, которое будет выполняться при нажатии

    var body: some View {
        Button(action: action) {
            ZStack {
                Image(iconName)
                    .resizable()
                    .font(.title3)
                    .foregroundColor(.primary)
                    .frame(width: 24, height: 24)
            }
            .frame(width: 50, height: 50)
            .background(
                Circle()
                    .stroke(.accent, lineWidth: 1)
            )
        }
    }
}
