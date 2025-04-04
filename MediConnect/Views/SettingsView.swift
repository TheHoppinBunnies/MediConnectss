//
//  SettingsView.swift
//  MediConnect
//
//  Created by Othmane EL MARIKY on 2025-03-21.
//

import SwiftUI

struct HealthDataSettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var healthDataAccess = true
    @State private var appleHealthIntegration = true
    @State private var autoSync = true
    @State private var syncFrequency = "Hourly"

    let syncOptions = ["Hourly", "Every 6 Hours", "Daily", "Manual Only"]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Health Data Access")) {
                    Toggle("Allow Health Data Access", isOn: $healthDataAccess)
                    Toggle("Apple Health Integration", isOn: $appleHealthIntegration)
                }

                Section(header: Text("Sync Settings")) {
                    Toggle("Auto Sync Data", isOn: $autoSync)

                    if autoSync {
                        Picker("Sync Frequency", selection: $syncFrequency) {
                            ForEach(syncOptions, id: \.self) { option in
                                Text(option)
                            }
                        }
                    }

                    Button("Sync Now") {
                        // Trigger sync
                    }
                    .disabled(!healthDataAccess)
                }

                Section(header: Text("Connected Devices")) {
                    NavigationLink(destination: EmptyView()) {
                        Label("Apple Watch", systemImage: "applewatch")
                    }

                    NavigationLink(destination: EmptyView()) {
                        Label("Connect New Device", systemImage: "plus.circle")
                    }
                }
            }
            .navigationTitle("Health Data Settings")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct NotificationSettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var appointmentReminders = true
    @State private var medicationReminders = true
    @State private var healthAlerts = true
    @State private var doctorMessages = true
    @State private var generalUpdates = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Allow Notifications")) {
                    Toggle("Appointment Reminders", isOn: $appointmentReminders)
                    Toggle("Medication Reminders", isOn: $medicationReminders)
                    Toggle("Health Alerts", isOn: $healthAlerts)
                    Toggle("Doctor Messages", isOn: $doctorMessages)
                    Toggle("General Updates", isOn: $generalUpdates)
                }

                Section(header: Text("Reminder Settings")) {
                    NavigationLink(destination: EmptyView()) {
                        Text("Appointment Reminder Timing")
                    }

                    NavigationLink(destination: EmptyView()) {
                        Text("Medication Reminder Timing")
                    }
                }
            }
            .navigationTitle("Notifications")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct PrivacySettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var enableTwoFactor = false
    @State private var shareHealthData = true
    @State private var useBiometrics = true
    @State private var locationAccess = "While Using"

    let locationOptions = ["Always", "While Using", "Never"]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Account Security")) {
                    Toggle("Two-Factor Authentication", isOn: $enableTwoFactor)
                    Toggle("Use Face ID / Touch ID", isOn: $useBiometrics)

                    NavigationLink(destination: EmptyView()) {
                        Text("Change Password")
                    }
                }

                Section(header: Text("Privacy")) {
                    Toggle("Share Health Data with Doctors", isOn: $shareHealthData)

                    Picker("Location Access", selection: $locationAccess) {
                        ForEach(locationOptions, id: \.self) { option in
                            Text(option)
                        }
                    }

                    NavigationLink(destination: EmptyView()) {
                        Text("Manage Permissions")
                    }
                }

                Section(header: Text("Data Management")) {
                    NavigationLink(destination: EmptyView()) {
                        Text("Download My Data")
                    }

                    Button("Delete All Data") {
                        // Show confirmation dialog
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Privacy & Security")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct AboutView: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Image(systemName: "heart.text.square.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .foregroundColor(.blue)

                    Text("MediConnect")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Version 1.0.0")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    VStack(alignment: .leading, spacing: 15) {
                        Text("About MediConnect")
                            .font(.headline)
                            .padding(.bottom, 5)

                        Text("MediConnect is an AI-powered telemedicine application designed to provide accessible healthcare through technology. Our platform connects patients with healthcare providers and uses artificial intelligence to offer preliminary consultations and health monitoring.")

                        Text("Features include AI consultations, video calls with doctors, appointment scheduling, medication management, vital sign monitoring, and emergency services.")

                        Text("This application is for demonstration purposes and is not intended for actual medical use without proper certification and regulatory approval.")
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)

                    Button("Contact Support") {
                        // Open support contact options
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)

                    Text("© 2025 MediConnect Inc. All rights reserved.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top)
                }
                .padding()
            }
            .navigationTitle("About")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
