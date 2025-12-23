//
//  LocationViewModel.swift
//  Parent
//
//  Created by Michail Shagovitov on 16.12.2025.
//

import SwiftUI
import MapKit
import Combine

import SwiftUI
import MapKit
import Combine

@MainActor
class LocationViewModel: ObservableObject {
    @Published var children: [Child] = []
    @Published var selectedChild: Child?
    @Published var childCoordinates: [String: CLLocationCoordinate2D] = [:]
    @Published var childStreetNames: [String: String] = [:]
    @Published var batteryStatuses: [String: (level: Float, state: String)] = [:]
    @Published var isLoading = false
    @Published var isPinging: [String: Bool] = [:]
    
    private var stateManager: AppStateManager
    private var cloudKitManager: CloudKitManager
    private var cancellables = Set<AnyCancellable>()
    
    init(stateManager: AppStateManager, cloudKitManager: CloudKitManager) {
        self.stateManager = stateManager
        self.cloudKitManager = cloudKitManager
        setupBindings()
        
        NotificationCenter.default.publisher(for: .commandUpdated)
            .sink { [weak self] notification in
                self?.handleCommandUpdate(notification)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods

    func getStreetName(for childID: String) -> String {
        return childStreetNames[childID, default: "Обновление..."]
    }

    func getBatteryText(for childID: String) -> String {
        guard let status = batteryStatuses[childID] else { return "--%" }
        return "\(Int(status.level * 100))%"
    }
    
    func getBatteryColor(for childID: String) -> Color {
        guard let status = batteryStatuses[childID] else { return .strokeTextField }
        if status.state == "charging" || status.state == "full" { return .chartStart }
        if status.level <= 0.2 { return .warningStart }
        if status.level <= 0.5 { return .questionStart }
        return .chartStart
    }
    
    func requestLocationUpdateForSelectedChild() {
        guard let child = selectedChild else { return }
        
        // Проверяем, не идет ли уже запрос для этого ребенка
        guard isPinging[child.recordID, default: false] == false else { return }
        
        print("📍->PING: Запрос на обновление локации для \(child.name)...")
        isPinging[child.recordID] = true
        
        Task {
            do {
                // 1. Отправляем "пинг" команду через CloudKitManager
                try await cloudKitManager.sendCommand(name: "request_location_update", to: child.recordID)
                
                // 2. Ждем 10-15 секунд, чтобы дать ребенку время получить GPS и ответить
                try await Task.sleep(for: .seconds(15))
                
                print("PONG->📍: Время ожидания вышло. Запрашиваем свежий статус...")
                // 3. Запрашиваем обновление статуса ТОЛЬКО для этого ребенка
                await fetchAndProcessStatus(for: child)
                
            } catch {
                print("❌ Ошибка отправки 'ping' команды: \(error)")
            }
        }
    }
    
    
    // MARK: - Data Fetching Logic

    /// Главная функция для обновления всех данных
    func fetchAllStatuses() {
        guard !children.isEmpty else { return }
        isLoading = true
        
        Task {
            // Асинхронно запрашиваем статус для КАЖДОГО ребенка
            await withTaskGroup(of: Void.self) { group in
                for child in children {
                    group.addTask {
                        await self.fetchAndProcessStatus(for: child)
                    }
                }
            }
            isLoading = false
        }
    }
    
    // MARK: - Private Methods
    
    private func handleCommandUpdate(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let statusRaw = userInfo["status"] as? String,
              let commandName = userInfo["commandName"] as? String,
              let childID = userInfo["childID"] as? String
        else { return }

        // Проверяем, касается ли это текущего выбранного ребенка
        if let selected = selectedChild, selected.recordID == childID {
            
            if statusRaw == CommandStatus.executed.rawValue {
                if commandName == "request_location_update" {
                    isPinging[childID] = false
                }
            }
        }
    }
    
    private func setupBindings() {
        // Подписка на список детей
        stateManager.$children
            .sink { [weak self] children in
                self?.children = children
            }
            .store(in: &cancellables)
            
        // При смене ребенка или при первом запуске - обновляем данные
        $selectedChild
            .sink { [weak self] _ in
                // Можно добавить логику обновления только для выбранного,
                // но fetchAllStatuses уже достаточно оптимизирован.
            }
            .store(in: &cancellables)
    }
    
    /// Главная логика загрузки и обработки данных для ОДНОГО ребенка
    private func fetchAndProcessStatus(for child: Child) async {
        do {
            guard let status = try await cloudKitManager.fetchDeviceStatus(for: child.recordID) else {
                self.childStreetNames[child.recordID] = "Нет данных о местоположении"
                return
            }
            
            self.batteryStatuses[child.recordID] = (status.batteryLevel, status.batteryState)
            if let location = status.location {
                self.childCoordinates[child.recordID] = location.coordinate
                await self.reverseGeocode(location: location, for: child.recordID)
            } else {
                self.childStreetNames[child.recordID] = "Координаты не определены"
            }
            
        } catch {
            print("❌ Ошибка загрузки статуса для \(child.name): \(error)")
            self.childStreetNames[child.recordID] = "Ошибка загрузки"
        }
    }
    
    /// Логика геокодирования
    private func reverseGeocode(location: CLLocation, for childID: String) async {
        let geocoder = CLGeocoder()
        do {
            if let placemark = try await geocoder.reverseGeocodeLocation(location).first {
                self.childStreetNames[childID] = formatAddress(from: placemark)
            }
        } catch {
            print("❌ Ошибка геокодирования: \(error.localizedDescription)")
            self.childStreetNames[childID] = "Не удалось определить адрес"
        }
    }
    
    private func formatAddress(from placemark: CLPlacemark) -> String {
        var addressParts: [String] = []
        if let street = placemark.thoroughfare {
            addressParts.append(street)
            if let houseNumber = placemark.subThoroughfare {
                addressParts.append(houseNumber)
            }
        } else if let poi = placemark.name {
            addressParts.append(poi)
        } else {
            return placemark.locality ?? "Неизвестное место"
        }
        return addressParts.joined(separator: ", ")
    }
}
