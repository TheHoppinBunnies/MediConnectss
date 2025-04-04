//
//  AppointmentsView.swift
//  MediConnect
//
//  Created by Othmane EL MARIKY on 2025-03-21.
//

import SwiftUI
import WebKit

struct AppointmentsView: View {
    @EnvironmentObject var appState: AppState
    @State private var showingBookAppointment = false
    @State private var selectedSegment = 0

    var body: some View {
        NavigationView {
            VStack {
                Picker("", selection: $selectedSegment) {
                    Text("Upcoming").tag(0)
                    Text("Past").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)

                if selectedAppointments.isEmpty {
                    ContentUnavailableView(
                        label: {
                            Label(selectedSegment == 0 ? "No Upcoming Appointments" : "No Past Appointments",
                                  systemImage: "calendar.badge.exclamationmark")
                        },
                        description: {
                            Text(selectedSegment == 0 ? "Schedule an appointment with a doctor" : "Your past appointments will appear here")
                        },
                        actions: {
                            if selectedSegment == 0 {
                                Button("Book Appointment") {
                                    showingBookAppointment = true
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                    )
                } else {
                    List {
                        ForEach(selectedAppointments) { appointment in
                            AppointmentRow(appointment: appointment)
                        }
                    }
                }
            }
            .navigationTitle("Appointments")
            .navigationBarItems(trailing:
                Button(action: {
                    showingBookAppointment = true
                }) {
                    Image(systemName: "plus")
                }
            )
            .sheet(isPresented: $showingBookAppointment) {
                BookAppointmentView()
            }
        }
    }

    private var selectedAppointments: [Appointment] {
        if selectedSegment == 0 {
            return appState.appointments.filter { $0.date > Date() && $0.status == .scheduled }
                .sorted { $0.date < $1.date }
        } else {
            return appState.appointments.filter { $0.date < Date() || $0.status == .cancelled }
                .sorted { $0.date > $1.date }
        }
    }
}

struct AppointmentRow: View {
    let appointment: Appointment

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(appointment.doctorName)
                    .font(.headline)
                Spacer()
                StatusBadge(status: appointment.status)
            }

            Text(appointment.specialty)
                .font(.subheadline)
                .foregroundColor(.secondary)

            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.blue)
                Text(dateFormatter.string(from: appointment.date))

                Image(systemName: "clock")
                    .foregroundColor(.blue)
                    .padding(.leading, 5)
                Text(timeFormatter.string(from: appointment.date))
            }
            .font(.caption)
            .padding(.top, 2)

            HStack {
                Image(systemName: appointment.isVideoCall ? "video.fill" : "person.fill")
                    .foregroundColor(.blue)
                Text(appointment.isVideoCall ? "Video Call" : "In-person")
                    .font(.caption)
            }
        }
        .padding(.vertical, 5)
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

struct StatusBadge: View {
    let status: Appointment.AppointmentStatus

    var body: some View {
        Text(status.rawValue.capitalized)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(statusColor)
            .foregroundColor(.white)
            .cornerRadius(5)
    }

    private var statusColor: Color {
        switch status {
        case .scheduled:
            return .blue
        case .completed:
            return .green
        case .cancelled:
            return .red
        }
    }
}

struct BookAppointmentView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedDoctor = "Dr. Sarah Johnson"
    @State private var selectedSpecialty = "Cardiology"
    @State private var selectedDate = Date().addingTimeInterval(86400)
    @State private var notes = ""
    @State private var isVideoCall = true

    let doctors = ["Dr. Sarah Johnson", "Dr. Michael Chen", "Dr. Lisa Rodriguez"]
    let specialties = ["Cardiology", "General Practice", "Dermatology", "Neurology", "Pediatrics"]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Doctor")) {
                    Picker("Doctor", selection: $selectedDoctor) {
                        ForEach(doctors, id: \.self) { doctor in
                            Text(doctor)
                        }
                    }
                    .pickerStyle(DefaultPickerStyle())

                    Picker("Specialty", selection: $selectedSpecialty) {
                        ForEach(specialties, id: \.self) { specialty in
                            Text(specialty)
                        }
                    }
                    .pickerStyle(DefaultPickerStyle())
                }

                Section(header: Text("Date & Time")) {
                    DatePicker("Date & Time", selection: $selectedDate, in: Date()...)
                }

                Section(header: Text("Appointment Type")) {
                    Toggle("Video Call", isOn: $isVideoCall)
                }

                Section(header: Text("Reason for Visit")) {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }

                Section {
                    Button("Schedule Appointment") {
                        // Save the new appointment
                        presentationMode.wrappedValue.dismiss()
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(.blue)
                }
            }
            .navigationTitle("Book Appointment")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

//MARK: WEB VIEW FOR APPOINTMENTS

struct WebView: UIViewRepresentable {
    let url: URL
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}

struct AppointmentsWebView: View {
    var body: some View {
        WebView(url: URL(string: "https://rvsq.gouv.qc.ca/prendrerendezvous/Principale.aspx")!)
            .edgesIgnoringSafeArea(.all)
    }
}
