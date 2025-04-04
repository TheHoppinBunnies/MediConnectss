//
//  HomeView.swift
//  MediConnect
//
//  Created by Othmane EL MARIKY on 2025-03-21.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @State private var showEmergencyAlert = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Emergency Button
                    Button(action: {
                        showEmergencyAlert = true
                    }) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 22))
                            Text("Emergency")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }

                    // Quick Actions
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                        NavigationLink(destination: VideoCallView(isAI: true)) {
                            QuickActionButton(icon: "video.fill", title: "AI Consultation", color: .blue)
                        }

                        NavigationLink(destination: NearbyHospitalsView()) {
                            QuickActionButton(icon: "building.2.fill", title: "Nearby Hospitals", color: .green)
                        }

                        NavigationLink(destination: VitalSignsView()) {
                            QuickActionButton(icon: "waveform.path.ecg", title: "Vital Signs", color: .orange)
                        }

                        NavigationLink(destination: ChatView()) {
                            QuickActionButton(icon: "message.fill", title: "Chat with AI", color: .purple)
                        }
                    }

                    // Upcoming Appointments
                    VStack(alignment: .leading) {
                        Text("Upcoming Appointments")
                            .font(.headline)
                            .padding(.bottom, 5)

                        if let nextAppointment = appState.appointments.filter({ $0.status == .scheduled && $0.date > Date() }).sorted(by: { $0.date < $1.date }).first {
                            AppointmentCard(appointment: nextAppointment)
                        } else {
                            Text("No upcoming appointments")
                                .foregroundColor(.secondary)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                        }

                        NavigationLink(destination: AppointmentsView()) {
                            Text("View All")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                                .padding(.top, 5)
                        }
                    }

                    // Medication Reminders
                    VStack(alignment: .leading) {
                        Text("Medication Reminders")
                            .font(.headline)
                            .padding(.bottom, 5)

                        ForEach(appState.medications.prefix(2)) { medication in
                            MedicationReminderCard(medication: medication)
                        }

                        NavigationLink(destination: MedicationsView()) {
                            Text("View All")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                                .padding(.top, 5)
                        }
                    }

                    // Recent Vital Signs
                    VStack(alignment: .leading) {
                        Text("Recent Vital Signs")
                            .font(.headline)
                            .padding(.bottom, 5)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(appState.vitalSigns.prefix(4)) { vitalSign in
                                    VitalSignCard(vitalSign: vitalSign)
                                }
                            }
                        }

                        NavigationLink(destination: VitalSignsView()) {
                            Text("View All")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                                .padding(.top, 5)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("MediConnect")
            .alert(isPresented: $showEmergencyAlert) {
                Alert(
                    title: Text("Emergency"),
                    message: Text("Call emergency services (911)?"),
                    primaryButton: .destructive(Text("Call 911")) {
                        // In a real app, this would use URL(string: "tel:911") to call
                        print("Calling 911")
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color

    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct AppointmentCard: View {
    let appointment: Appointment

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(appointment.doctorName)
                    .font(.headline)
                Text(appointment.specialty)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                HStack {
                    Image(systemName: appointment.isVideoCall ? "video.fill" : "person.fill")
                    Text(appointment.isVideoCall ? "Video Call" : "In Person")
                }
                .font(.caption)
                .foregroundColor(.blue)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 5) {
                Text(dateFormatter.string(from: appointment.date))
                    .font(.subheadline)
                Text(timeFormatter.string(from: appointment.date))
                    .font(.headline)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter
    }

    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }
}

struct MedicationReminderCard: View {
    let medication: Medication

    var body: some View {
        HStack {
            Image(systemName: "pill.fill")
                .font(.system(size: 25))
                .foregroundColor(.blue)
                .padding(.trailing, 5)

            VStack(alignment: .leading, spacing: 4) {
                Text(medication.name)
                    .font(.headline)
                Text("\(medication.dosage) - \(medication.instructions)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if let nextDose = medication.schedule.first(where: { $0 > Date() }) {
                Text(timeFormatter.string(from: nextDose))
                    .font(.headline)
                    .foregroundColor(.orange)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }

    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }
}

struct VitalSignCard: View {
    let vitalSign: VitalSign

    var body: some View {
        VStack(alignment: .center, spacing: 5) {
            Text(vitalSign.type.rawValue)
                .font(.caption)
                .foregroundColor(.secondary)

            Text("\(Int(vitalSign.value))")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(vitalSignColor(for: vitalSign))

            Text(vitalSign.unit)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(width: 100, height: 100)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }

    func vitalSignColor(for vitalSign: VitalSign) -> Color {
        switch vitalSign.type {
        case .heartRate:
            if vitalSign.value < 60 || vitalSign.value > 100 {
                return .orange
            }
        case .bloodPressure:
            if vitalSign.value > 130 {
                return .red
            }
        case .bloodOxygen:
            if vitalSign.value < 95 {
                return .orange
            } else if vitalSign.value < 90 {
                return .red
            }
        case .temperature:
            if vitalSign.value > 99.5 {
                return .orange
            } else if vitalSign.value > 100.4 {
                return .red
            }
        case .respiratoryRate:
            if vitalSign.value < 12 || vitalSign.value > 20 {
                return .orange
            }
        }
        return .green
    }
}
