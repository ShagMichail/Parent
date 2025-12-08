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
    private var locationUpdatesTimer: Timer?
    
    @Published var currentLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus
    @Published var lastKnownLocations: [LocationHistory] = []
    @Published var isTracking = false
    private var requestedInitialPermission = false
    
    private let maxLocationsHistory = 100
    private let cloudKitManager = CloudKitManager.shared
    
    override init() {
        authorizationStatus = locationManager.authorizationStatus
        super.init()
        
        setupLocationManager()
        print("📍 LocationManager инициализирован. Статус: \(authorizationStatus.rawValue)")
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = 10
        locationManager.activityType = .otherNavigation
        locationManager.showsBackgroundLocationIndicator = true
    }
    
    // MARK: - Public Methods
    
    func requestPermission() -> Bool {
        print("📍 Запрашиваем разрешение на геолокацию...")
        
        let currentStatus = locationManager.authorizationStatus
        print("   Текущий статус: \(statusDescription(currentStatus))")
        
        switch currentStatus {
        case .notDetermined:
            print("📱 Показываем системный диалог разрешения...")
            
            // Важно: запрашиваем сначала .whenInUse
            // iOS сам предложит .always позже
            locationManager.requestWhenInUseAuthorization()
            requestedInitialPermission = true
            return true // Диалог показан
            
        case .authorizedWhenInUse:
            print("⚠️ Уже есть .whenInUse. Запрашиваем .always...")
            locationManager.requestAlwaysAuthorization()
            return true
            
        case .authorizedAlways:
            print("✅ Уже есть .always. Ничего не делаем")
            return false
            
        case .denied, .restricted:
            print("❌ Доступ запрещен. Нужно открыть настройки")
            showOpenSettingsAlert()
            return false
            
        @unknown default:
            return false
        }
    }

    private func statusDescription(_ status: CLAuthorizationStatus) -> String {
        switch status {
        case .notDetermined: return "notDetermined"
        case .restricted: return "restricted"
        case .denied: return "denied"
        case .authorizedAlways: return "authorizedAlways"
        case .authorizedWhenInUse: return "authorizedWhenInUse"
        @unknown default: return "unknown"
        }
    }
    
    private func showOpenSettingsAlert() {
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: "Доступ к геолокации запрещен",
                message: "Пожалуйста, разрешите доступ к геолокации в настройках для отслеживания местоположения",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "Открыть настройки", style: .default) { _ in
                self.openAppSettings()
            })
            
            alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
            
            // Показываем алерт на главном окне
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                rootVC.present(alert, animated: true)
            }
        }
    }

    private func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
    
    func startTracking() {
        print("📍 Пытаемся запустить отслеживание...")
        print("   Статус авторизации: \(authorizationStatus.rawValue)")
        
        // Если разрешение еще не запрашивали - запрашиваем
        if authorizationStatus == .notDetermined && !requestedInitialPermission {
            print("⚠️ Разрешение не запрошено. Сначала запрашиваем...")
            requestPermission()
            return
        }
        
        switch authorizationStatus {
        case .authorizedAlways:
            print("✅ Есть .authorizedAlways - запускаем полное отслеживание")
            startFullTracking()
            
        case .authorizedWhenInUse:
            print("⚠️ Только .authorizedWhenInUse - запрашиваем .authorizedAlways")
            // Пока запускаем базовое отслеживание
            startBasicTracking()
            // И запрашиваем полный доступ
            locationManager.requestAlwaysAuthorization()
            
        case .denied, .restricted:
            print("❌ Доступ запрещен. Открываем настройки")
            openSettings()
            
        case .notDetermined:
            print("⏳ Разрешение еще не дано. Ждем ответа пользователя")
            // Ничего не делаем, ждем callback в locationManagerDidChangeAuthorization
            
        @unknown default:
            break
        }
    }
    
    private func startFullTracking() {
        print("🚀 Запуск полного отслеживания с фоновым режимом")
        
        // Настраиваем для фоновой работы
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
        
        startLocationUpdatesTimer()
        isTracking = true
    }
    
    private func startBasicTracking() {
        print("🚀 Запуск базового отслеживания (только когда приложение активно)")
        
        locationManager.allowsBackgroundLocationUpdates = false
        locationManager.startUpdatingLocation()
        
        startLocationUpdatesTimer()
        isTracking = true
    }
    
    func stopTracking() {
        locationManager.stopUpdatingLocation()
        locationManager.stopMonitoringSignificantLocationChanges()
        stopLocationUpdatesTimer()
        isTracking = false
        
        print("📍 Отслеживание остановлено")
    }
    
    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    
    // MARK: - Делегат CLLocationManager
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            let oldStatus = self.authorizationStatus
            self.authorizationStatus = manager.authorizationStatus
            
            print("📍 Статус авторизации изменился:")
            print("   Было: \(oldStatus.rawValue)")
            print("   Стало: \(self.authorizationStatus.rawValue)")
            
            switch self.authorizationStatus {
            case .authorizedAlways:
                print("✅ Пользователь дал .authorizedAlways!")
                
                // Если трекинг уже запущен - перезапускаем с фоновым режимом
                if self.isTracking {
                    print("🔄 Перезапускаем трекинг с фоновым режимом")
                    self.stopTracking()
                    self.setupLocationManager() // Сбрасываем настройки
                    self.startFullTracking()    // Запускаем с фоновым режимом
                }
                
            case .authorizedWhenInUse:
                print("⚠️ Пользователь дал только .authorizedWhenInUse")
                
                // Если трекинг не запущен, но нужно - запускаем базовый
                if !self.isTracking {
                    self.startBasicTracking()
                }
                
            case .denied, .restricted:
                print("❌ Пользователь отказал в доступе")
                self.stopTracking()
                
            case .notDetermined:
                print("⏳ Пользователь еще не принял решение")
                
            @unknown default:
                break
            }
        }
    }
    
    func getCurrentLocation() -> CLLocation? {
        return currentLocation
    }
    
    func getLocationHistory() -> [LocationHistory] {
        return lastKnownLocations
    }
    
    // MARK: - Private Methods
    
    private func startLocationUpdatesTimer() {
        // Отправляем обновления каждые 5 минут
        locationUpdatesTimer = Timer.scheduledTimer(
            withTimeInterval: 300, // 5 минут
            repeats: true
        ) { [weak self] _ in
            guard let self = self else { return }
            
            // Переходим на главный поток перед вызовом
//            DispatchQueue.main.async {
//                self.sendLocationUpdateToCloud()
//            }
        }
    }
    
    private func stopLocationUpdatesTimer() {
        locationUpdatesTimer?.invalidate()
        locationUpdatesTimer = nil
    }
    
//    @MainActor private func sendLocationUpdateToCloud() {
//        guard let location = currentLocation,
//              let childID = AuthenticationManager.shared.myUserRecordID else {
//            return
//        }
//        
//        Task {
//            do {
//                let recordID = try await cloudKitManager.sendLocationUpdate(
//                    latitude: location.coordinate.latitude,
//                    longitude: location.coordinate.longitude,
//                    timestamp: Date(),
//                    childID: childID
//                )
//                print("📍 Геопозиция отправлена в CloudKit: \(recordID)")
//            } catch {
//                print("❌ Ошибка отправки геопозиции: \(error)")
//            }
//        }
//    }
    
    private func addToHistory(_ location: CLLocation) {
        let locationHistory = LocationHistory(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            timestamp: Date(),
            accuracy: location.horizontalAccuracy
        )
        
        lastKnownLocations.insert(locationHistory, at: 0)
        
        if lastKnownLocations.count > maxLocationsHistory {
            lastKnownLocations = Array(lastKnownLocations.prefix(maxLocationsHistory))
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        DispatchQueue.main.async {
            self.currentLocation = location
            self.addToHistory(location)
            
//            if location.horizontalAccuracy < 50 {
//                self.sendLocationUpdateToCloud()
//            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Ошибка геолокации: \(error.localizedDescription)")
    }
}

// MARK: - Модели данных
//struct LocationHistory: Identifiable, Codable {
//    let id = UUID()
//    let latitude: Double
//    let longitude: Double
//    let timestamp: Date
//    let accuracy: Double
//    
//    var coordinate: CLLocationCoordinate2D {
//        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
//    }
//}
