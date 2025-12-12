//
//  DeviceStatusManager.swift
//  Parent
//
//  Created by Michail Shagovitov on 10.12.2025.
//

import UIKit

class DeviceStatusManager {
    static let shared = DeviceStatusManager()
    
    init() {
        // Обязательно нужно включить мониторинг, иначе вернет -1.0
        UIDevice.current.isBatteryMonitoringEnabled = true
    }
    
    func getCurrentBatteryInfo() -> (level: Float, state: String) {
        let level = UIDevice.current.batteryLevel // От 0.0 до 1.0
        
        let state: String
        switch UIDevice.current.batteryState {
        case .charging: state = "charging"
        case .full: state = "full"
        case .unplugged: state = "unplugged"
        case .unknown: state = "unknown"
        @unknown default: state = "unknown"
        }
        
        return (level, state)
    }
}
