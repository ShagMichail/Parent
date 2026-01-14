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
    @State private var navigateToNotifications = false
    
    @Binding var isTabBarVisible: Bool
    
    @EnvironmentObject var notificationViewModel: NotificationViewModel
    
    init(stateManager: AppStateManager, cloudKitManager: CloudKitManager, isTabBarVisible: Binding<Bool>) {
        _viewModel = StateObject(wrappedValue: LocationViewModel(
            stateManager: stateManager,
            cloudKitManager: cloudKitManager
        ))
        _isTabBarVisible = isTabBarVisible
    }
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    // Карта
                    Map(position: $cameraPosition) {
                        ForEach(viewModel.children) { child in
                            if let coordinate = viewModel.childCoordinates[child.recordID] {
                                Annotation("", coordinate: coordinate) {
                                    PinContentView(
                                        model: PinContentViewModel(
                                            child: child,
                                            isSelected: child.recordID == viewModel.selectedChild?.recordID,
                                            onTap: {
                                                withAnimation {
                                                    viewModel.selectedChild = child
                                                }
                                            }
                                        )
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
                                FloatingActionButton(
                                    model: FloatingActionButtonModel(
                                        iconName: "notification",
                                        action: {
                                            navigateToNotifications.toggle()
                                            isTabBarVisible.toggle()
                                        }
                                    )
                                )
                                Spacer()
                                FloatingActionButton(
                                    model: FloatingActionButtonModel(
                                        iconName: "current-location",
                                        action: {
                                            print("🎯 Кнопка 'Мое местоположение' нажата")
                                        }
                                    )
                                )
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
                        
                        // Инфо-карточка появляется здесь
                        if let selectedChild = viewModel.selectedChild {
                            let isPingingBinding = Binding<Bool>(
                                get: { viewModel.isPinging[selectedChild.recordID, default: false] },
                                set: { _ in }
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
                        .padding(.bottom, 60)
                    }
                    
                    if viewModel.isLoading {
                        ProgressView()
                            .scaleEffect(1.5)
                            .progressViewStyle(.circular)
                    }
                }
                .ignoresSafeArea(.keyboard)
            }
            .navigationBarHidden(true)
            .onAppear {
                viewModel.fetchAllStatuses()
            }
            .onChange(of: viewModel.selectedChild) { _, newChild in
                if newChild != nil {
                    updateCameraPosition()
                }
            }
            .navigationDestination(
                isPresented: $navigateToNotifications,
                destination: { NotificationView(showNavigationBar: $isTabBarVisible) }
            )
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
