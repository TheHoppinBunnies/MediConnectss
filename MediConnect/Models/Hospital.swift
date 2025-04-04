//
//  Hospital.swift
//  MediConnect
//
//  Created by Othmane EL MARIKY on 2025-03-22.
//

import Foundation
import CoreLocation

struct Hospital: Identifiable {
    let id: UUID
    let name: String
    let address: String
    let distance: Double
    let coordinates: CLLocationCoordinate2D
    let phone: String
    let rating: Double
}

