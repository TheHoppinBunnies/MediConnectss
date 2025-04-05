//
//  VitalSign.swift
//  MediConnect
//
//  Created by Othmane EL MARIKY on 2025-03-22.
//

import Foundation
import HealthKit
//
//struct VitalSign: Identifiable {
//    let id: UUID
//    let type: VitalType
//    let value: Double
//    let unit: String
//    let timestamp: Date
//
//    enum VitalType: String {
//        case heartRate = "Heart Rate"
//        case bloodPressure = "Blood Pressure"
//        case bloodOxygen = "Blood Oxygen"
//        case temperature = "Temperature"
//        case respiratoryRate = "Respiratory Rate"
//    }
//}

struct VitalSign: Identifiable {
    let id = UUID()
    let type: VitalType
    let value: Double
    let unit: String
    let timestamp: Date

    enum VitalType: String, CaseIterable {
        case heartRate = "Heart Rate"
        case bloodPressure = "Blood Pressure"
        case bloodOxygen = "Blood Oxygen"
        case temperature = "Temperature"
        case respiratoryRate = "Respiratory Rate"
    }

    static func mapHealthType(_ type: HKQuantityType) -> VitalType? {
        if type == HKQuantityType.quantityType(forIdentifier: .heartRate) {
            return .heartRate
        } else if type == HKQuantityType.quantityType(forIdentifier: .bloodPressureSystolic) ||
                  type == HKQuantityType.quantityType(forIdentifier: .bloodPressureDiastolic) {
            return .bloodPressure
        } else if type == HKQuantityType.quantityType(forIdentifier: .oxygenSaturation) {
            return .bloodOxygen
        } else if type == HKQuantityType.quantityType(forIdentifier: .bodyTemperature) {
            return .temperature
        } else if type == HKQuantityType.quantityType(forIdentifier: .respiratoryRate) {
            return .respiratoryRate
        }
        return nil
    }
}
