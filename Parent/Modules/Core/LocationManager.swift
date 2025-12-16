//
//  LocationManager.swift
//  Parent
//
//  Created by Михаил Шаговитов on 02.12.2025.
//

import CoreLocation
import Combine
import UIKit

class LocationManager: NSObject, ObservableObject {
    static let shared = LocationManager()
    
    private let locationManager = CLLocationManager()
    
    @Published var currentLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus
    @Published var lastKnownLocations: [LocationHistory] = []
    @Published var isTracking = false
    
    // Для управления частотой отправки в CloudKit
    private var lastUploadTime: Date?
    // Интервал отправки в секундах (например, раз в 5 минут)
    private let uploadInterval: TimeInterval = 300
    
    private var requestedInitialPermission = false
    private let maxLocationsHistory = 100
    private let cloudKitManager = CloudKitManager.shared
    
    override init() {
        authorizationStatus = locationManager.authorizationStatus
        super.init()
        
        setupLocationManager()
        // ✅ Включаем мониторинг батареи
        UIDevice.current.isBatteryMonitoringEnabled = true
        
        print("📍 LocationManager инициализирован. Статус: \(authorizationStatus.rawValue)")
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        // Для навигации точность высокая, но это ест батарею.
        // Для родительского контроля часто достаточно kCLLocationAccuracyHundredMeters
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // Фильтр дистанции: обновлять только если сдвинулся на 50 метров
        locationManager.distanceFilter = 50
        
        locationManager.activityType = .other
        locationManager.showsBackgroundLocationIndicator = true
        
        // Критично для работы в фоне
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
    }
    
    // MARK: - Public Methods
    
    func startTracking() {
        print("📍 Запрос на запуск трекинга...")
        
        switch locationManager.authorizationStatus {
        case .notDetermined:
            // ЕЩЕ НЕ РЕШИЛИ: Запрашиваем права и ВЫХОДИМ.
            // Трекинг запустится сам в locationManagerDidChangeAuthorization, когда юзер нажмет "ОК"
            print("⏳ Прав нет. Запрашиваем разрешение...")
            locationManager.requestAlwaysAuthorization()
            return
            
        case .denied, .restricted:
            print("❌ Доступ к геолокации запрещен пользователем.")
            return
            
        case .authorizedAlways, .authorizedWhenInUse:
            // ПРАВА ЕСТЬ: Можно запускать
            print("✅ Права есть. Запускаем обновление координат.")
        @unknown default:
            break
        }
        // Принудительно включаем фоновый режим
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        
        locationManager.startUpdatingLocation()
        // Мониторинг значительных изменений (работает даже если приложение убито)
        locationManager.startMonitoringSignificantLocationChanges()
        
        isTracking = true
    }
    
    func stopTracking() {
        locationManager.stopUpdatingLocation()
        locationManager.stopMonitoringSignificantLocationChanges()
        isTracking = false
        print("📍 Отслеживание остановлено")
    }
    
    func requestPermission() {
        locationManager.requestAlwaysAuthorization()
    }
    
    func forceSendStatus() {
        print("📍 Получен запрос на принудительную отправку статуса.")
        
        // Используем последнюю известную локацию, которая уже есть у менеджера.
        // `locationManager.location` хранит самое свежее значение.
        guard let location = locationManager.location else {
            print("⚠️ Невозможно принудительно отправить статус: последняя локация неизвестна.")
            return
        }
        
        // Вызываем вашу существующую функцию сбора и отправки
        collectAndSendStatus(location: location)
    }
    
    
    // MARK: - Private Logic
    
    private func addToHistory(_ location: CLLocation) {
        let historyItem = LocationHistory(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            timestamp: Date(),
            accuracy: location.horizontalAccuracy
        )
        
        DispatchQueue.main.async {
            self.lastKnownLocations.insert(historyItem, at: 0)
            if self.lastKnownLocations.count > self.maxLocationsHistory {
                self.lastKnownLocations = Array(self.lastKnownLocations.prefix(self.maxLocationsHistory))
            }
        }
    }
    
    // ✅ Сбор данных о батарее и локации
    private func collectAndSendStatus(location: CLLocation) {
        // 1. Получаем инфо о батарее
        let batteryLevel = UIDevice.current.batteryLevel
        let batteryState = getBatteryStateString()
        
        // 2. Формируем пакет
        let status = ChildDeviceStatus(
            location: location,
            batteryLevel: batteryLevel,
            batteryState: batteryState,
            timestamp: Date()
        )
        
        print("🔋 Батарея: \(Int(status.batteryLevel * 100))%, \(status.batteryState)")
        print("📍 Локация: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        
        // 3. Отправляем в CloudKit
        Task {
            do {
                try await cloudKitManager.sendDeviceStatus(status)
            } catch {
                print("❌ Ошибка отправки статуса в CloudKit: \(error)")
            }
        }
    }
    
    private func getBatteryStateString() -> String {
        switch UIDevice.current.batteryState {
        case .charging: return "charging"
        case .full: return "full"
        case .unplugged: return "unplugged"
        case .unknown: return "unknown"
        @unknown default: return "unknown"
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            self.authorizationStatus = manager.authorizationStatus
            if self.authorizationStatus == .authorizedAlways || self.authorizationStatus == .authorizedWhenInUse {
                self.startTracking()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        // Обновляем UI
        DispatchQueue.main.async {
            self.currentLocation = location
            self.addToHistory(location)
        }
        
        // ✅ ЛОГИКА ОТПРАВКИ (Троттлинг)
        // Проверяем, прошло ли достаточно времени с последней отправки
        let now = Date()
        if let lastTime = lastUploadTime, now.timeIntervalSince(lastTime) < uploadInterval {
            // Если прошло меньше 5 минут — пропускаем отправку в облако,
            // чтобы экономить батарею и трафик.
            // Но локально данные обновили (см. выше).
            return
        }
        
        // Если времени прошло достаточно — отправляем
        lastUploadTime = now
        collectAndSendStatus(location: location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Ошибка LocationManager: \(error.localizedDescription)")
    }
}
