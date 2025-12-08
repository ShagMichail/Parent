////
////  ChildLocationView.swift
////  Parent
////
////  Created by Михаил Шаговитов on 02.12.2025.
////
//
//import SwiftUI
//import MapKit
//
//struct ChildLocationView: View {
//    let child: Child
//    @StateObject private var locationManager = LocationManager.shared
//    @StateObject private var viewModel: ChildLocationViewModel
//    @State private var region: MKCoordinateRegion
//    @State private var selectedTimeRange = TimeRange.today
//    @State private var showingSettings = false
//    @State private var isLoading = false
//    
//    enum TimeRange: String, CaseIterable {
//        case hour = "Час"
//        case today = "Сегодня"
//        case week = "Неделя"
//        case all = "Вся история"
//        
//        var hours: Int {
//            switch self {
//            case .hour: return 1
//            case .today: return 24
//            case .week: return 168
//            case .all: return 720 // 30 дней
//            }
//        }
//    }
//    
//    
//    init(child: Child) {
//        self.child = child
//        
//        // Инициализируем ViewModel
//        _viewModel = StateObject(wrappedValue: ChildLocationViewModel(childID: child.id.uuidString))
//        
//        // Начальный регион
//        _region = State(initialValue: MKCoordinateRegion(
//            center: CLLocationCoordinate2D(latitude: 55.7558, longitude: 37.6173),
//            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
//        ))
//    }
//    
//    var body: some View {
//        ZStack {
//            // Карта
//            Map(coordinateRegion: $region,
//                showsUserLocation: false,
//                annotationItems: viewModel.locations) { location in
//                MapAnnotation(coordinate: location.coordinate) {
//                    LocationAnnotationView(
//                        location: location,
//                        isCurrent: location.id == viewModel.locations.first?.id
//                    )
//                }
//            }
//                .ignoresSafeArea()
//            
//            // Элементы управления
//            VStack {
//                headerView
//                Spacer()
//                controlsView
//            }
//            .padding()
//            
//            if viewModel.isLoading {
//                ProgressView()
//                    .scaleEffect(1.5)
//                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//                    .background(Color.black.opacity(0.3))
//            }
//        }
//        .navigationTitle("Местоположение")
//        .navigationBarTitleDisplayMode(.inline)
//        .onAppear {
//            // Загружаем данные при появлении
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                viewModel.loadLocationData(hours: selectedTimeRange.hours)
//            }
//        }
//        .onChange(of: selectedTimeRange) { _, newValue in
//            viewModel.loadLocationData(hours: newValue.hours)
//        }
//    }
//    
//    // MARK: - Компоненты
//    
//    private var headerView: some View {
//        HStack {
//            // Информация о статусе
//            VStack(alignment: .leading, spacing: 4) {
//                Text(child.name)
//                    .font(.title2)
//                    .fontWeight(.bold)
//                    .foregroundColor(.primary)
//                
//                HStack(spacing: 6) {
//                    Circle()
//                        .fill(viewModel.isOnline ? Color.green : Color.gray)
//                        .frame(width: 8, height: 8)
//                    
//                    Text(viewModel.isOnline ? "Онлайн" : "Офлайн")
//                        .font(.caption)
//                        .foregroundColor(.secondary)
//                    
//                    if let lastSeen = viewModel.lastUpdateTime {
//                        Text("• \(lastSeen, style: .relative) назад")
//                            .font(.caption2)
//                            .foregroundColor(.secondary)
//                    }
//                }
//            }
//            
//            Spacer()
//            
//            // Кнопка настроек
//            Button(action: { showingSettings.toggle() }) {
//                Image(systemName: "gear")
//                    .font(.headline)
//                    .foregroundColor(.blue)
//                    .padding(10)
//                    .background(Circle().fill(Color.blue.opacity(0.1)))
//            }
//        }
//        .padding()
//        .background(
//            RoundedRectangle(cornerRadius: 16)
//                .fill(Color(.systemBackground))
//                .shadow(color: .black.opacity(0.1), radius: 10)
//        )
//    }
//    
//    private var mapOverlay: some View {
//        VStack(spacing: 12) {
//            // Селектор времени
//            Picker("Период", selection: $selectedTimeRange) {
//                ForEach(TimeRange.allCases, id: \.self) { range in
//                    Text(range.rawValue).tag(range)
//                }
//            }
//            .pickerStyle(.segmented)
//            .padding(.horizontal)
//            
//            // Информация о местоположении
//            if let currentLocation = viewModel.locations.first {
//                LocationInfoCard(location: currentLocation)
//                    .padding(.horizontal)
//            }
//        }
//        .padding(.vertical, 12)
//        .background(
//            RoundedRectangle(cornerRadius: 20)
//                .fill(Color(.systemBackground))
//                .shadow(color: .black.opacity(0.1), radius: 10)
//        )
//        .padding(.horizontal)
//        .padding(.bottom, 20)
//    }
//    
//    private var controlsView: some View {
//        HStack(spacing: 16) {
//            // Кнопка обновления
//            Button(action: loadLocationData) {
//                Image(systemName: "arrow.clockwise")
//                    .font(.headline)
//                    .foregroundColor(.white)
//                    .padding(14)
//                    .background(Circle().fill(Color.blue))
//            }
//            
//            // Кнопка центрации
//            Button(action: centerOnCurrentLocation) {
//                Image(systemName: "location.fill")
//                    .font(.headline)
//                    .foregroundColor(.white)
//                    .padding(14)
//                    .background(Circle().fill(Color.green))
//            }
//            
//            // Кнопка истории
//            Button(action: {}) {
//                Image(systemName: "clock.arrow.circlepath")
//                    .font(.headline)
//                    .foregroundColor(.white)
//                    .padding(14)
//                    .background(Circle().fill(Color.orange))
//            }
//        }
//    }
//    
//    // MARK: - Методы
//    
//    private func loadLocationData() {
//        isLoading = true
//        
//        Task {
//            do {
//                let locations = try await CloudKitManager.shared.fetchLocationHistory(
//                    for: child.recordID,
//                    hours: selectedTimeRange.hours
//                )
//                
//                await MainActor.run {
//                    viewModel.locations = locations
//                    
//                    if let firstLocation = locations.first {
//                        region = MKCoordinateRegion(
//                            center: firstLocation.coordinate,
//                            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
//                        )
//                    }
//                    isLoading = false
//                }
//            } catch {
//                print("❌ Ошибка загрузки геолокации: \(error)")
//                await MainActor.run {
//                    isLoading = false
//                }
//            }
//        }
//    }
//    
//    private func setupLocationTracking() {
//        // Если это устройство ребенка - запускаем трекинг
//        if AuthenticationManager.shared.userRole == .child {
//            LocationManager.shared.startTracking()
//            
//            // Подписываемся на обновления
//            Task {
//                try? await CloudKitManager.shared.subscribeToLocationUpdates(for: child.recordID)
//            }
//        }
//    }
//    
//    private func centerOnCurrentLocation() {
//        guard let firstLocation = viewModel.locations.first else { return }
//        
//        withAnimation(.spring()) {
//            region = MKCoordinateRegion(
//                center: firstLocation.coordinate,
//                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
//            )
//        }
//    }
//}
//
//
