//
//  Appointment.swift
//  MediConnect
//
//  Created by Othmane EL MARIKY on 2025-03-22.
//

import Foundation

struct Appointment: Identifiable {
    let id: UUID
    let doctorName: String
    let specialty: String
    let date: Date
    let isVideoCall: Bool
    var status: AppointmentStatus

    enum AppointmentStatus: String {
        case scheduled, completed, cancelled
    }
}
