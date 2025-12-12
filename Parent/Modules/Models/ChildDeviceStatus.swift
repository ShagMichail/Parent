//
//  ChildDeviceStatus 2.swift
//  Parent
//
//  Created by Michail Shagovitov on 10.12.2025.
//

import CoreLocation

struct ChildDeviceStatus {
    let location: CLLocation
    let batteryLevel: Float      // от 0.0 до 1.0
    let batteryState: String     // "charging", "unplugged", "full", "unknown"
    let timestamp: Date
}
