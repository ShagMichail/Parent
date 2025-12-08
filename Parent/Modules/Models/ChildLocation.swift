//
//  ChildLocation.swift
//  Parent
//
//  Created by Михаил Шаговитов on 02.12.2025.
//

import Foundation
import CloudKit

struct ChildLocation: Identifiable {
    let id: CKRecord.ID
    let childID: String
    let latitude: Double
    let longitude: Double
    let timestamp: Date
    let accuracy: Double?
    let deviceName: String?
    let batteryLevel: Float?
    let isCharging: Bool?
    
    init?(from record: CKRecord) {
        guard let childID = record["childID"] as? String,
              let latitude = record["latitude"] as? Double,
              let longitude = record["longitude"] as? Double,
              let timestamp = record["timestamp"] as? Date else {
            return nil
        }
        
        self.id = record.recordID
        self.childID = childID
        self.latitude = latitude
        self.longitude = longitude
        self.timestamp = timestamp
        self.accuracy = record["accuracy"] as? Double
        self.deviceName = record["deviceName"] as? String
        self.batteryLevel = record["batteryLevel"] as? Float
        self.isCharging = record["isCharging"] as? Bool
    }
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var location: CLLocation {
        CLLocation(latitude: latitude, longitude: longitude)
    }
}

