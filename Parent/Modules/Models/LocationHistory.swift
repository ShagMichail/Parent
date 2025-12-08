//
//  LocationHistory.swift
//  Parent
//
//  Created by Михаил Шаговитов on 02.12.2025.
//

import Foundation
import CoreLocation

struct LocationHistory: Identifiable, Codable {
    let id = UUID()
    let latitude: Double
    let longitude: Double
    let timestamp: Date
    let accuracy: Double
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
