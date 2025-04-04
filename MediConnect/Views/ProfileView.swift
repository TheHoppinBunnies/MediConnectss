//
//  ProfileView.swift
//  MediConnect
//
//  Created by Othmane EL MARIKY on 2025-03-21.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @State private var showingHealthSettings = false
    @State private var showingNotificationSettings = false
    @State private var showingPrivacySettings = false
    @State private var showingAbout = false
    @State private var showingLogoutAlert = false

    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        Image(systemName: appState.user?.profileImage ?? "person.crop.circle")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 70, height: 70)
                            .clipShape(Circle())
                            .foregroundColor(.blue)

                        VStack(alignment: .leading, spacing: 5) {
                            Text(appState.user?.name ?? "User")
                                .font(.headline)
                            Text(appState.user?.email ?? "")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.leading, 5)
                    }
                    .padding(.vertical, 5)

                    NavigationLink(destination: EditProfileView()) {
                        Label("Edit Profile", systemImage: "pencil")
                    }
                }

                Section(header: Text("Medical Information")) {
                    NavigationLink(destination: MedicalProfileView()) {
                        Label("Medical Profile", systemImage: "heart.text.square")
                    }

                    NavigationLink(destination: EmptyView()) {
                        Label("Insurance Information", systemImage: "doc.text")
                    }

                    NavigationLink(destination: EmptyView()) {
                        Label("Emergency Contacts", systemImage: "phone.fill")
                    }
                }

                Section(header: Text("Settings")) {
                    Button(action: {
                        showingHealthSettings = true
                    }) {
                        Label("Health Data Settings", systemImage: "heart.fill")
                    }

                    Button(action: {
                        showingNotificationSettings = true
                    }) {
                        Label("Notifications", systemImage: "bell.fill")
                    }

                    Button(action: {
                        showingPrivacySettings = true
                    }) {
                        Label("Privacy & Security", systemImage: "lock.fill")
                    }
                }

                Section(header: Text("About")) {
                    Button(action: {
                        showingAbout = true
                    }) {
                        Label("About MediConnect", systemImage: "info.circle")
                    }

                    NavigationLink(destination: EmptyView()) {
                        Label("Help & Support", systemImage: "questionmark.circle")
                    }

                    NavigationLink(destination: EmptyView()) {
                        Label("Terms of Service", systemImage: "doc.text")
                    }
                }

                Section {
                    Button(action: {
                        showingLogoutAlert = true
                    }) {
                        HStack {
                            Spacer()
                            Text("Sign Out")
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Profile")
            .sheet(isPresented: $showingHealthSettings) {
                HealthDataSettingsView()
            }
            .sheet(isPresented: $showingNotificationSettings) {
                NotificationSettingsView()
            }
            .sheet(isPresented: $showingPrivacySettings) {
                PrivacySettingsView()
            }
            .sheet(isPresented: $showingAbout) {
                AboutView()
            }
            .alert(isPresented: $showingLogoutAlert) {
                Alert(
                    title: Text("Sign Out"),
                    message: Text("Are you sure you want to sign out?"),
                    primaryButton: .destructive(Text("Sign Out")) {
//                        appState.logout()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
}

struct EditProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appState: AppState
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var phone: String = "555-123-4567"

    var body: some View {
        Form {
            Section(header: Text("Personal Information")) {
                HStack {
                    Spacer()

                    Image(systemName: appState.user?.profileImage ?? "person.crop.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .foregroundColor(.blue)

                    Spacer()
                }
                .padding()

                Button("Change Photo") {
                    // Photo picker would be implemented here
                }
                .frame(maxWidth: .infinity, alignment: .center)

                TextField("Name", text: $name)
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                TextField("Phone", text: $phone)
                    .keyboardType(.phonePad)
            }

            Section {
                Button("Save Changes") {
                    // Save changes and dismiss
                    presentationMode.wrappedValue.dismiss()
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .foregroundColor(.blue)
            }
        }
        .navigationTitle("Edit Profile")
        .onAppear {
            // Load user data
            if let user = appState.user {
                name = user.name
                email = user.email
            }
        }
    }
}

struct MedicalProfileView: View {
    @EnvironmentObject var appState: AppState
    @State private var isEditing = false
    @State private var dateOfBirth = Date(timeIntervalSince1970: 0)
    @State private var bloodType = "O+"
    @State private var height = "5'10\""
    @State private var weight = "160 lbs"
    @State private var allergies = ["Peanuts", "Penicillin"]
    @State private var conditions = ["Asthma"]

    let bloodTypes = ["O+", "O-", "A+", "A-", "B+", "B-", "AB+", "AB-"]

    var body: some View {
        Form {
            Section(header: Text("Basic Information")) {
                if isEditing {
                    DatePicker("Date of Birth", selection: $dateOfBirth, displayedComponents: .date)

                    Picker("Blood Type", selection: $bloodType) {
                        ForEach(bloodTypes, id: \.self) { type in
                            Text(type)
                        }
                    }

                    TextField("Height", text: $height)
                    TextField("Weight", text: $weight)
                } else {
                    HStack {
                        Text("Date of Birth")
                        Spacer()
                        Text(dateFormatter.string(from: dateOfBirth))
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Blood Type")
                        Spacer()
                        Text(bloodType)
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Height")
                        Spacer()
                        Text(height)
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Weight")
                        Spacer()
                        Text(weight)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Section(header: Text("Allergies")) {
                if isEditing {
                    ForEach(allergies.indices, id: \.self) { index in
                        TextField("Allergy", text: $allergies[index])
                    }

                    Button("Add Allergy") {
                        allergies.append("")
                    }
                } else {
                    if allergies.isEmpty {
                        Text("No known allergies")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(allergies, id: \.self) { allergy in
                            Text(allergy)
                        }
                    }
                }
            }

            Section(header: Text("Medical Conditions")) {
                if isEditing {
                    ForEach(conditions.indices, id: \.self) { index in
                        TextField("Condition", text: $conditions[index])
                    }

                    Button("Add Condition") {
                        conditions.append("")
                    }
                } else {
                    if conditions.isEmpty {
                        Text("No known medical conditions")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(conditions, id: \.self) { condition in
                            Text(condition)
                        }
                    }
                }
            }
        }
        .navigationTitle("Medical Profile")
        .navigationBarItems(trailing:
            Button(isEditing ? "Done" : "Edit") {
                isEditing.toggle()
            }
        )
        .onAppear {
            // Load user data
            if let user = appState.user {
                dateOfBirth = user.dateOfBirth
                bloodType = user.bloodType
                allergies = user.allergies
                conditions = user.conditions
            }
        }
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
}
