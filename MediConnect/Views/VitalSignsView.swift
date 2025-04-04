//
//  VitalSignsView.swift
//  MediConnect
//
//  Created by Othmane EL MARIKY on 2025-03-21.
//

import SwiftUI

struct VitalSignsView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Vital signs cards
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                    ForEach(vitalSignsByType.keys.sorted(by: { $0.rawValue < $1.rawValue }), id: \.self) { type in
                        if let latestVital = vitalSignsByType[type]?.first {
                            VitalSignDetailCard(vitalSign: latestVital, history: vitalSignsByType[type] ?? [])
                        }
                    }
                }
                .padding()

                // Connect to wearable devices button
                Button(action: {
                    // Action to connect to wearable devices
                }) {
                    HStack {
                        Image(systemName: "applewatch")
                        Text("Connect to Apple Watch")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
                }

                // Health Reports
                VStack(alignment: .leading) {
                    Text("Health Reports")
                        .font(.headline)
                        .padding(.horizontal)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            HealthReportCard(title: "Monthly Health Summary", date: "Mar 2025", icon: "chart.bar.fill")
                            HealthReportCard(title: "Heart Health Report", date: "Feb 2025", icon: "heart.fill")
                            HealthReportCard(title: "Sleep Analysis", date: "Jan 2025", icon: "bed.double.fill")
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Vital Signs")
        }
    }

    // Group vital signs by type and sort by date (newest first)
    private var vitalSignsByType: [VitalSign.VitalType: [VitalSign]] {
        Dictionary(grouping: appState.vitalSigns, by: { $0.type })
            .mapValues { values in
                values.sorted(by: { $0.timestamp > $1.timestamp })
            }
    }
}

struct VitalSignDetailCard: View {
    let vitalSign: VitalSign
    let history: [VitalSign]
    @State private var showingHistory = false

    var body: some View {
        Button(action: {
            showingHistory = true
        }) {
            VStack(spacing: 10) {
                Image(systemName: iconForVitalType(vitalSign.type))
                    .font(.system(size: 30))
                    .foregroundColor(.blue)

                Text(vitalSign.type.rawValue)
                    .font(.headline)

                Text("\(Int(vitalSign.value)) \(vitalSign.unit)")
                    .font(.title2)
                    .foregroundColor(vitalSignColor(for: vitalSign))

                Text("Last updated: \(timeAgo(from: vitalSign.timestamp))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .frame(height: 180)
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingHistory) {
            VitalSignHistoryView(vitalType: vitalSign.type, history: history)
        }
    }

    func iconForVitalType(_ type: VitalSign.VitalType) -> String {
        switch type {
        case .heartRate:
            return "heart.fill"
        case .bloodPressure:
            return "waveform.path.ecg"
        case .bloodOxygen:
            return "lungs.fill"
        case .temperature:
            return "thermometer"
        case .respiratoryRate:
            return "wind"
        }
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

    func timeAgo(from date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.minute, .hour, .day], from: date, to: now)

        if let day = components.day, day > 0 {
            return "\(day) day\(day == 1 ? "" : "s") ago"
        } else if let hour = components.hour, hour > 0 {
            return "\(hour) hour\(hour == 1 ? "" : "s") ago"
        } else if let minute = components.minute, minute > 0 {
            return "\(minute) minute\(minute == 1 ? "" : "s") ago"
        } else {
            return "Just now"
        }
    }
}

struct VitalSignHistoryView: View {
    let vitalType: VitalSign.VitalType
    let history: [VitalSign]
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            List {
                ForEach(history) { vital in
                    HStack {
                        VStack(alignment: .leading) {
                            Text("\(Int(vital.value)) \(vital.unit)")
                                .font(.headline)
                            Text(dateFormatter.string(from: vital.timestamp))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        // Trend indicator
                        if let previousValue = getPreviousValue(for: vital) {
                            Image(systemName: getTrendIcon(current: vital.value, previous: previousValue))
                                .foregroundColor(getTrendColor(current: vital.value, previous: previousValue))
                        }
                    }
                    .padding(.vertical, 5)
                }
            }
            .navigationTitle("\(vitalType.rawValue) History")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }

    func getPreviousValue(for vital: VitalSign) -> Double? {
        guard let index = history.firstIndex(where: { $0.id == vital.id }),
              index < history.count - 1 else {
            return nil
        }

        return history[index + 1].value
    }

    func getTrendIcon(current: Double, previous: Double) -> String {
        let difference = current - previous
        if abs(difference) < 0.01 {
            return "equal"
        } else if difference > 0 {
            return "arrow.up"
        } else {
            return "arrow.down"
        }
    }

    func getTrendColor(current: Double, previous: Double) -> Color {
        switch vitalType {
        case .heartRate, .bloodPressure, .temperature:
            // For these vitals, an increase might be concerning
            return current > previous ? .orange : .green
        case .bloodOxygen:
            // For blood oxygen, an increase is generally good
            return current > previous ? .green : .orange
        case .respiratoryRate:
            // For respiratory rate, stability is preferred
            return abs(current - previous) < 2 ? .green : .orange
        }
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy 'at' h:mm a"
        return formatter
    }
}

struct HealthReportCard: View {
    let title: String
    let date: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(.blue)
                Spacer()
                Image(systemName: "doc.text")
                    .foregroundColor(.gray)
            }

            Spacer()

            Text(title)
                .font(.headline)
                .lineLimit(2)

            Text(date)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(width: 170, height: 150)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}
