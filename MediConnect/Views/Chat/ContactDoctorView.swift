//
//  ContactDoctorView.swift
//  MediConnect
//
//  Created by Othmane EL MARIKY on 2025-03-22.
//

import SwiftUI

struct ContactDoctorView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedDoctor: String = "Dr. Sarah Johnson"
    @State private var reason: String = ""

    let doctors = [
        "Dr. Sarah Johnson (Cardiology)",
        "Dr. Michael Chen (General Practice)",
        "Dr. Lisa Rodriguez (Dermatology)"
    ]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Contact a Doctor")) {
                    Picker("Select Doctor", selection: $selectedDoctor) {
                        ForEach(doctors, id: \.self) { doctor in
                            Text(doctor)
                        }
                    }

                    TextField("Reason for consultation", text: $reason)
                        .frame(height: 100, alignment: .top)
                        .multilineTextAlignment(.leading)
                }

                Section {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                        // This would navigate to VideoCallView in a real app
                    }) {
                        HStack {
                            Image(systemName: "video.fill")
                            Text("Start Video Call")
                        }
                    }
                    .foregroundColor(.blue)

                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                        // This would navigate to ChatView with doctor in a real app
                    }) {
                        HStack {
                            Image(systemName: "message.fill")
                            Text("Send Message")
                        }
                    }
                    .foregroundColor(.green)
                }
            }
            .navigationTitle("Contact Doctor")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
