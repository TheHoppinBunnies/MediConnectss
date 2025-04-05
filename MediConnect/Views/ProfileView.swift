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

import HealthKit

struct MedicalProfileView: View {
    @EnvironmentObject var appState: AppState
    @State private var isEditing = false
    @State private var dateOfBirth = Date(timeIntervalSince1970: 0)
    @State private var bloodType = "O+"
    @State private var height = "5'10\""
    @State private var weight = "160 lbs"
    @State private var allergies = ["Peanuts", "Penicillin"]
    @State private var conditions = ["Asthma"]
    @State private var usesMedicalID = false
    @State private var healthStore: HKHealthStore?
    @State private var medicalIDFetched = false

    let bloodTypes = ["O+", "O-", "A+", "A-", "B+", "B-", "AB+", "AB-"]

    var body: some View {
        Form {
            Section(header: Text("Data Source")) {
                Toggle("Use Medical ID Data", isOn: $usesMedicalID)
                    .onChange(of: usesMedicalID) { newValue in
                        if newValue {
                            requestMedicalIDAccess()
                        }
                    }
            }

            Section(header: Text("Basic Information")) {
                if isEditing && !usesMedicalID {
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
                if isEditing && !usesMedicalID {
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
                if isEditing && !usesMedicalID {
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

            if usesMedicalID && !medicalIDFetched {
                Section {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                    Text("Fetching Medical ID data...")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .navigationTitle("Medical Profile")
        .navigationBarItems(trailing:
            Button(isEditing ? "Done" : "Edit") {
                if usesMedicalID {
                    // Show alert that editing is disabled when using Medical ID
                    // This is a placeholder for where you'd show an alert
                    print("Cannot edit when using Medical ID")
                } else {
                    isEditing.toggle()
                }
            }
            .disabled(usesMedicalID)
        )
        .onAppear {
            setupHealthKit()

            // Load user data
            if let user = appState.user {
                dateOfBirth = user.dateOfBirth
                bloodType = user.bloodType
                allergies = user.allergies
                conditions = user.conditions
            }
        }
    }

    private func setupHealthKit() {
        if HKHealthStore.isHealthDataAvailable() {
            healthStore = HKHealthStore()
        }
    }

    private func requestMedicalIDAccess() {
        guard let healthStore = healthStore else {
            return
        }

        // Define the health data types your app will read
        let readTypes: Set<HKObjectType> = [
            HKObjectType.characteristicType(forIdentifier: .dateOfBirth)!,
            HKObjectType.characteristicType(forIdentifier: .bloodType)!,
            HKObjectType.quantityType(forIdentifier: .height)!,
            HKObjectType.quantityType(forIdentifier: .bodyMass)!
            // Note: Medical conditions and allergies aren't directly available through HealthKit
            // They are part of the Medical ID but not exposed through the API
        ]

        healthStore.requestAuthorization(toShare: nil, read: readTypes) { success, error in
            if success {
                DispatchQueue.main.async {
                    self.fetchMedicalIDData()
                }
            } else if let error = error {
                print("Authorization failed: \(error.localizedDescription)")
            }
        }
    }

    private func fetchMedicalIDData() {
        guard let healthStore = healthStore else {
            return
        }

        // Fetch date of birth
        do {
            let dateOfBirthComponents = try healthStore.dateOfBirthComponents()
            if let dob = Calendar.current.date(from: dateOfBirthComponents) {
                DispatchQueue.main.async {
                    self.dateOfBirth = dob
                }
            }
        } catch {
            print("Failed to fetch date of birth: \(error.localizedDescription)")
        }

        // Fetch blood type
        do {
            let bloodTypeValue = try healthStore.bloodType().bloodType

            let bloodTypeString: String
            switch bloodTypeValue {
            case .aPositive:
                bloodTypeString = "A+"
            case .aNegative:
                bloodTypeString = "A-"
            case .bPositive:
                bloodTypeString = "B+"
            case .bNegative:
                bloodTypeString = "B-"
            case .abPositive:
                bloodTypeString = "AB+"
            case .abNegative:
                bloodTypeString = "AB-"
            case .oPositive:
                bloodTypeString = "O+"
            case .oNegative:
                bloodTypeString = "O-"
            case .notSet:
                bloodTypeString = "Unknown"
            @unknown default:
                bloodTypeString = "Unknown"
            }

            DispatchQueue.main.async {
                self.bloodType = bloodTypeString
            }
        } catch {
            print("Failed to fetch blood type: \(error.localizedDescription)")
        }

        // Fetch height
        let heightType = HKQuantityType.quantityType(forIdentifier: .height)!
        let heightQuery = HKSampleQuery(sampleType: heightType, predicate: nil, limit: 1, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]) { _, samples, error in
            if let heightSample = samples?.first as? HKQuantitySample {
                let heightInMeters = heightSample.quantity.doubleValue(for: HKUnit.meter())

                // Convert to feet and inches for display
                let heightInFeet = heightInMeters * 3.28084
                let feet = Int(heightInFeet)
                let inches = Int((heightInFeet - Double(feet)) * 12)

                DispatchQueue.main.async {
                    self.height = "\(feet)'\(inches)\""
                }
            } else if let error = error {
                print("Failed to fetch height: \(error.localizedDescription)")
            }
        }

        healthStore.execute(heightQuery)

        // Fetch weight
        let weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass)!
        let weightQuery = HKSampleQuery(sampleType: weightType, predicate: nil, limit: 1, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]) { _, samples, error in
            if let weightSample = samples?.first as? HKQuantitySample {
                let weightInKg = weightSample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))

                // Convert to pounds for display
                let weightInLbs = Int(weightInKg * 2.20462)

                DispatchQueue.main.async {
                    self.weight = "\(weightInLbs) lbs"
                }
            } else if let error = error {
                print("Failed to fetch weight: \(error.localizedDescription)")
            }
        }

        healthStore.execute(weightQuery)

        // Note: For medical conditions and allergies, you can't access them directly through HealthKit API
        // Users would need to enter these manually or you could consider using other methods

        DispatchQueue.main.async {
            self.medicalIDFetched = true
        }
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
}
