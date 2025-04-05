//
//  SampleData.swift
//  MediConnect
//
//  Created by Othmane EL MARIKY on 2025-03-21.
//

import SwiftUI
import CoreLocation

// MARK: - Sample Appointments
let sampleAppointments: [Appointment] = [
    Appointment(id: UUID(), doctorName: "Dr. Sarah Johnson", specialty: "Cardiology", date: Date().addingTimeInterval(86400), isVideoCall: true, status: .scheduled),
    Appointment(id: UUID(), doctorName: "Dr. Michael Chen", specialty: "General Practice", date: Date().addingTimeInterval(-172800), isVideoCall: false, status: .completed),
    Appointment(id: UUID(), doctorName: "Dr. Lisa Rodriguez", specialty: "Dermatology", date: Date().addingTimeInterval(432000), isVideoCall: true, status: .scheduled)
]

// MARK: - Sample Medications
let sampleMedications: [Medication] = [
    Medication(id: UUID(), name: "Lisinopril", dosage: "10mg", schedule: [Date()], instructions: "Take once daily with food", refillDate: Date().addingTimeInterval(1296000)),
    Medication(id: UUID(), name: "Metformin", dosage: "500mg", schedule: [Date(), Date().addingTimeInterval(43200)], instructions: "Take twice daily with meals", refillDate: Date().addingTimeInterval(864000)),
    Medication(id: UUID(), name: "Ibuprofen", dosage: "200mg", schedule: [Date()], instructions: "Take as needed for pain", refillDate: nil)
]

// MARK: - Sample Vital Signs
//let sampleVitalSigns: [VitalSign] = [
//    VitalSign(id: UUID(), type: .heartRate, value: 72, unit: "bpm", timestamp: Date().addingTimeInterval(-3600)),
//    VitalSign(id: UUID(), type: .bloodPressure, value: 120/80, unit: "mmHg", timestamp: Date().addingTimeInterval(-7200)),
//    VitalSign(id: UUID(), type: .bloodOxygen, value: 98, unit: "%", timestamp: Date().addingTimeInterval(-3600)),
//    VitalSign(id: UUID(), type: .temperature, value: 98.6, unit: "°F", timestamp: Date().addingTimeInterval(-86400)),
//    VitalSign(id: UUID(), type: .respiratoryRate, value: 16, unit: "bpm", timestamp: Date().addingTimeInterval(-3600))
//]

// MARK: - Sample Chat History
//let sampleChatHistory: [ChatMessage] = [
//    ChatMessage(sender: "AI", content: "Hello! How can I help you today?", timestamp: Date().addingTimeInterval(-3600)),
//    ChatMessage(id: UUID(), sender: "user", content: "I've been having a sore throat for the past 3 days.", timestamp: Date().addingTimeInterval(-3540)),
//    ChatMessage(id: UUID(), sender: "AI", content: "I'm sorry to hear that. Do you have any other symptoms like fever or cough?", timestamp: Date().addingTimeInterval(-3500))
//]


// MARK: - Sample Hospitals
let sampleHospitals: [Hospital] = [
    Hospital(id: UUID(), name: "Memorial General Hospital", address: "123 Medical Ave, City", distance: 2.3, coordinates: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), phone: "555-123-4567", rating: 4.5),
    Hospital(id: UUID(), name: "City Medical Center", address: "456 Healthcare Blvd, City", distance: 3.8, coordinates: CLLocationCoordinate2D(latitude: 37.7833, longitude: -122.4167), phone: "555-987-6543", rating: 4.2),
    Hospital(id: UUID(), name: "University Hospital", address: "789 Treatment St, City", distance: 5.1, coordinates: CLLocationCoordinate2D(latitude: 37.7694, longitude: -122.4862), phone: "555-456-7890", rating: 4.7)
]
