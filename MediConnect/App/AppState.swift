//
//  AppState.swift
//  MediConnect
//
//  Created by Othmane EL MARIKY on 2025-03-21.
//

import SwiftUI
import CoreLocation

class AppState: ObservableObject {
    @Published var user: User?
    @AppStorage("isFirstTime") var isLoggedIn = true
    @Published var currentTab: Tab = .home
    @Published var appointments: [Appointment] = []
    @Published var medications: [Medication] = []
    @Published var vitalSigns: [VitalSign] = []
    @Published var chatHistory: [ChatMessage] = []
    @Published var nearbyHospitals: [Hospital] = []

    enum Tab {
        case home, chat, appointments, medications, profile
    }

    func loadUserData() {
        // Simulate loading data
        self.appointments = sampleAppointments
        self.medications = sampleMedications
//        self.vitalSigns = sampleVitalSigns
//        self.chatHistory = sampleChatHistory
    }

    func searchNearbyHospitals(location: CLLocation) {
        // This would use MKLocalSearch in a real implementation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.nearbyHospitals = sampleHospitals
        }
    }

    
}
