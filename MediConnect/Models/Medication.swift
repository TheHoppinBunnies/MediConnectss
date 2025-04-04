//
//  Medication.swift
//  MediConnect
//
//  Created by Othmane EL MARIKY on 2025-03-22.
//

import Foundation

struct Medication: Identifiable {
    let id: UUID
    let name: String
    let dosage: String
    let schedule: [Date]
    let instructions: String
    var refillDate: Date?
}
