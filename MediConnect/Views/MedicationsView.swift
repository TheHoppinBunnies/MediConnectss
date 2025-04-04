//
//  MedicationsView.swift
//  MediConnect
//
//  Created by Othmane EL MARIKY on 2025-03-21.
//

import SwiftUI

struct MedicationsView: View {
    @EnvironmentObject var appState: AppState
    @State private var showingAddMedication = false

    var body: some View {
        NavigationView {
            List {
                ForEach(appState.medications) { medication in
                    MedicationRow(medication: medication)
                }
            }
            .navigationTitle("Medications")
            .navigationBarItems(trailing:
                Button(action: {
                    showingAddMedication = true
                }) {
                    Image(systemName: "plus")
                }
            )
            .sheet(isPresented: $showingAddMedication) {
                AddMedicationView()
            }
        }
    }
}

struct MedicationRow: View {
    let medication: Medication

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "pill.fill")
                    .foregroundColor(.blue)
                    .font(.system(size: 22))

                Text(medication.name)
                    .font(.headline)

                Spacer()

                if let refillDate = medication.refillDate, refillDate < Date().addingTimeInterval(604800) {
                    Text("Refill soon")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(5)
                }
            }

            Text(medication.dosage)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text(medication.instructions)
                .font(.caption)
                .foregroundColor(.secondary)

            if !medication.schedule.isEmpty {
                HStack {
                    Image(systemName: "clock")
                        .foregroundColor(.blue)
                        .font(.system(size: 12))

                    Text(scheduleText(for: medication))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 5)
    }

    func scheduleText(for medication: Medication) -> String {
        if medication.schedule.count == 1 {
            return "Once daily at \(timeFormatter.string(from: medication.schedule[0]))"
        } else if medication.schedule.count == 2 {
            return "Twice daily at \(medication.schedule.map { timeFormatter.string(from: $0) }.joined(separator: " and "))"
        } else {
            return "\(medication.schedule.count) times daily"
        }
    }

    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }
}

struct AddMedicationView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var name = ""
    @State private var dosage = ""
    @State private var instructions = ""
    @State private var selectedTimes: [Date] = [Date()]
    @State private var frequency = "Once Daily"
    @State private var refillDate = Date().addingTimeInterval(2592000) // 30 days
    @State private var hasRefill = true

    let frequencies = ["Once Daily", "Twice Daily", "Three Times Daily", "Four Times Daily", "As Needed"]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Medication Details")) {
                    TextField("Medication Name", text: $name)
                    TextField("Dosage (e.g., 10mg)", text: $dosage)
                    TextField("Instructions", text: $instructions)
                }

                Section(header: Text("Schedule")) {
                    Picker("Frequency", selection: $frequency) {
                        ForEach(frequencies, id: \.self) { freq in
                            Text(freq)
                        }
                    }
                    .onChange(of: frequency) { _, newValue in
                        updateTimesBasedOnFrequency(newValue)
                    }

                    if frequency != "As Needed" {
                        ForEach(0..<selectedTimes.count, id: \.self) { index in
                            DatePicker("Time \(index + 1)", selection: $selectedTimes[index], displayedComponents: .hourAndMinute)
                        }
                    }
                }

                Section(header: Text("Refill")) {
                    Toggle("Needs Refill", isOn: $hasRefill)

                    if hasRefill {
                        DatePicker("Refill Date", selection: $refillDate, displayedComponents: .date)
                    }
                }

                Section {
                    Button("Save Medication") {
                        // Save the new medication
                        presentationMode.wrappedValue.dismiss()
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(.blue)
                }
            }
            .navigationTitle("Add Medication")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }

    func updateTimesBasedOnFrequency(_ frequency: String) {
        switch frequency {
        case "Once Daily":
            selectedTimes = [Date()]
        case "Twice Daily":
            selectedTimes = [
                Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date(),
                Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date()) ?? Date()
            ]
        case "Three Times Daily":
            selectedTimes = [
                Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date(),
                Calendar.current.date(bySettingHour: 14, minute: 0, second: 0, of: Date()) ?? Date(),
                Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date()) ?? Date()
            ]
        case "Four Times Daily":
            selectedTimes = [
                Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date(),
                Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date()) ?? Date(),
                Calendar.current.date(bySettingHour: 16, minute: 0, second: 0, of: Date()) ?? Date(),
                Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date()) ?? Date()
            ]
        case "As Needed":
            selectedTimes = []
        default:
            selectedTimes = [Date()]
        }
    }
}
