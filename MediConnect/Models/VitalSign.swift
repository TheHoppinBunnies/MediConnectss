//
//  VitalSign.swift
//  MediConnect
//
//  Created by Othmane EL MARIKY on 2025-03-22.
//

import Foundation

struct VitalSign: Identifiable {
    let id: UUID
    let type: VitalType
    let value: Double
    let unit: String
    let timestamp: Date

    enum VitalType: String {
        case heartRate = "Heart Rate"
        case bloodPressure = "Blood Pressure"
        case bloodOxygen = "Blood Oxygen"
        case temperature = "Temperature"
        case respiratoryRate = "Respiratory Rate"
    }
}
