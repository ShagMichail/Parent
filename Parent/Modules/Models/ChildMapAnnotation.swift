//
//  ChildMapAnnotation.swift
//  Parent
//
//  Created by Michail Shagovitov on 16.12.2025.
//

import Foundation
import MapKit

struct ChildMapAnnotation: Identifiable {
    let id: String
    let name: String
    var coordinate: CLLocationCoordinate2D
    var batteryLevel: Float
    var batteryState: String
}
