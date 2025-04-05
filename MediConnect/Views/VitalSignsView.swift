import SwiftUI
import HealthKit

struct VitalSignsView: View {
    @StateObject private var healthStore = HealthStore()
    @State private var vitalSigns: [VitalSign] = []
    @State private var isLoading = true

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if isLoading {
                    ProgressView("Loading health data...")
                        .padding()
                } else if vitalSigns.isEmpty {
                    Text("No health data available")
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    // Vital signs cards
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                        ForEach(vitalSignsByType.keys.sorted(by: { $0.rawValue < $1.rawValue }), id: \.self) { type in
                            if let latestVital = vitalSignsByType[type]?.first {
                                VitalSignDetailCard(vitalSign: latestVital, history: vitalSignsByType[type] ?? [])
                            }
                        }
                    }
                    .padding()
                }

                // Connect to wearable devices button
                Button(action: {
                    healthStore.requestAuthorization { success in
                        if success {
                            loadHealthData()
                        }
                    }
                }) {
                    HStack {
                        Image(systemName: "applewatch")
                        Text("Connect to Health Data")
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
            .onAppear {
                healthStore.requestAuthorization { success in
                    if success {
                        loadHealthData()
                    } else {
                        isLoading = false
                    }
                }
            }
        }
    }

    private func loadHealthData() {
        isLoading = true
        healthStore.fetchAllVitalSigns { fetchedVitals in
            self.vitalSigns = fetchedVitals
            self.isLoading = false
        }
    }

    // Group vital signs by type and sort by date (newest first)
    private var vitalSignsByType: [VitalSign.VitalType: [VitalSign]] {
        Dictionary(grouping: vitalSigns, by: { $0.type })
            .mapValues { values in
                values.sorted(by: { $0.timestamp > $1.timestamp })
            }
    }
}

// Model for Vital Signs


class HealthStore: ObservableObject {
    private var healthStore: HKHealthStore?

    init() {
        if HKHealthStore.isHealthDataAvailable() {
            healthStore = HKHealthStore()
        }
    }

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        guard let healthStore = self.healthStore else {
            completion(false)
            return
        }

        let typesToRead: [HKQuantityType] = [
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKQuantityType.quantityType(forIdentifier: .bloodPressureSystolic)!,
            HKQuantityType.quantityType(forIdentifier: .bloodPressureDiastolic)!,
            HKQuantityType.quantityType(forIdentifier: .oxygenSaturation)!,
            HKQuantityType.quantityType(forIdentifier: .bodyTemperature)!,
            HKQuantityType.quantityType(forIdentifier: .respiratoryRate)!
        ]

        healthStore.requestAuthorization(toShare: [], read: Set(typesToRead)) { success, error in
            DispatchQueue.main.async {
                completion(success)
            }
        }
    }

    func fetchAllVitalSigns(completion: @escaping ([VitalSign]) -> Void) {
        var vitalSigns: [VitalSign] = []
        let dispatchGroup = DispatchGroup()

        // Heart Rate
        dispatchGroup.enter()
        fetchVitalSign(for: .heartRate) { vitals in
            vitalSigns.append(contentsOf: vitals)
            dispatchGroup.leave()
        }

        // Blood Pressure (Systolic)
        dispatchGroup.enter()
        fetchVitalSign(for: .bloodPressure, valueType: .systolic) { vitals in
            vitalSigns.append(contentsOf: vitals)
            dispatchGroup.leave()
        }

        // Blood Oxygen
        dispatchGroup.enter()
        fetchVitalSign(for: .bloodOxygen) { vitals in
            vitalSigns.append(contentsOf: vitals)
            dispatchGroup.leave()
        }

        // Body Temperature
        dispatchGroup.enter()
        fetchVitalSign(for: .temperature) { vitals in
            vitalSigns.append(contentsOf: vitals)
            dispatchGroup.leave()
        }

        // Respiratory Rate
        dispatchGroup.enter()
        fetchVitalSign(for: .respiratoryRate) { vitals in
            vitalSigns.append(contentsOf: vitals)
            dispatchGroup.leave()
        }

        dispatchGroup.notify(queue: .main) {
            completion(vitalSigns)
        }
    }

    enum BPValueType {
        case systolic
        case diastolic
    }

    func fetchVitalSign(for vitalType: VitalSign.VitalType, valueType: BPValueType? = nil, completion: @escaping ([VitalSign]) -> Void) {
        guard let healthStore = self.healthStore else {
            completion([])
            return
        }

        var quantityType: HKQuantityType
        var unit: HKUnit

        switch vitalType {
        case .heartRate:
            quantityType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
            unit = HKUnit.count().unitDivided(by: HKUnit.minute())
        case .bloodPressure:
            if valueType == .diastolic {
                quantityType = HKQuantityType.quantityType(forIdentifier: .bloodPressureDiastolic)!
            } else {
                quantityType = HKQuantityType.quantityType(forIdentifier: .bloodPressureSystolic)!
            }
            unit = HKUnit.millimeterOfMercury()
        case .bloodOxygen:
            quantityType = HKQuantityType.quantityType(forIdentifier: .oxygenSaturation)!
            unit = HKUnit.percent()
        case .temperature:
            quantityType = HKQuantityType.quantityType(forIdentifier: .bodyTemperature)!
            unit = HKUnit.degreeCelsius()
        case .respiratoryRate:
            quantityType = HKQuantityType.quantityType(forIdentifier: .respiratoryRate)!
            unit = HKUnit.count().unitDivided(by: HKUnit.minute())
        }

        let startDate = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictStartDate)

        let query = HKSampleQuery(
            sampleType: quantityType,
            predicate: predicate,
            limit: 50,  // Adjust based on your needs
            sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)]
        ) { _, samples, error in
            var vitalSigns: [VitalSign] = []

            guard let samples = samples as? [HKQuantitySample], error == nil else {
                DispatchQueue.main.async {
                    completion([])
                }
                return
            }

            for sample in samples {
                let value = sample.quantity.doubleValue(for: unit)
                let unitString = self.getUnitString(for: vitalType)

                let vitalSign = VitalSign(
                    type: vitalType,
                    value: value,
                    unit: unitString,
                    timestamp: sample.endDate
                )
                vitalSigns.append(vitalSign)
            }

            DispatchQueue.main.async {
                completion(vitalSigns)
            }
        }

        healthStore.execute(query)
    }

    private func getUnitString(for vitalType: VitalSign.VitalType) -> String {
        switch vitalType {
        case .heartRate:
            return "BPM"
        case .bloodPressure:
            return "mmHg"
        case .bloodOxygen:
            return "%"
        case .temperature:
            return "Â°C"
        case .respiratoryRate:
            return "BrPM"
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

                Text("\(formatValue(vitalSign.value)) \(vitalSign.unit)")
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

    private func formatValue(_ value: Double) -> String {
        switch vitalSign.type {
        case .bloodOxygen:
            return String(format: "%.1f", value * 100) // Convert from decimal to percentage
        case .temperature:
            return String(format: "%.1f", value)
        default:
            return "\(Int(value))"
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
            let percentage = vitalSign.value * 100 // Convert from decimal to percentage
            if percentage < 95 {
                return .orange
            } else if percentage < 90 {
                return .red
            }
        case .temperature:
            if vitalSign.value > 37.5 { // 99.5Â°F in Celsius
                return .orange
            } else if vitalSign.value > 38 { // 100.4Â°F in Celsius
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
                            Text("\(formatValue(vital.value)) \(vital.unit)")
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

    private func formatValue(_ value: Double) -> String {
        switch vitalType {
        case .bloodOxygen:
            return String(format: "%.1f", value * 100) // Convert from decimal to percentage
        case .temperature:
            return String(format: "%.1f", value)
        default:
            return "\(Int(value))"
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
