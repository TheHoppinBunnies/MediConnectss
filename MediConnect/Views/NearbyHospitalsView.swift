import SwiftUI
import MapKit
import CoreLocation

// MARK: - Nearby Hospitals View
struct NearbyHospitalsView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var locationManager = LocationManager()
    @State private var searchText = ""
    @State private var selectedHospital: Hospital?
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var showingSearchResults = false
    @State private var mapItems: [MKMapItem] = []
    @State private var isSearching = false

    var body: some View {
        ZStack {
            // Map view
            Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: appState.nearbyHospitals) { hospital in
                MapAnnotation(coordinate: hospital.coordinates) {
                    Button(action: {
                        selectedHospital = hospital
                    }) {
                        VStack(spacing: 0) {
                            Image(systemName: "cross.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                                .frame(width: 32, height: 32)
                                .background(Circle().fill(Color.red))
                                .shadow(radius: 2)

                            if selectedHospital?.id == hospital.id {
                                Text(hospital.name)
                                    .font(.caption)
                                    .padding(5)
                                    .background(Color.white.opacity(0.8))
                                    .cornerRadius(5)
                                    .shadow(radius: 1)
                                    .fixedSize(horizontal: true, vertical: false)
                            }
                        }
                    }
                }
            }
            .edgesIgnoringSafeArea(.all)

            VStack {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)

                    TextField("Search hospitals", text: $searchText, onCommit: {
                        if !searchText.isEmpty {
                            searchHospitals()
                        }
                    })
                    .onChange(of: searchText) { _, newValue in
                        if newValue.isEmpty {
                            showingSearchResults = false
                        }
                    }

                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                            showingSearchResults = false
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }

                    Button(action: {
                        searchHospitals()
                    }) {
                        Text("Search")
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(5)
                    }
                    .disabled(searchText.isEmpty || isSearching)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(10)
                .shadow(radius: 2)
                .padding()

                // Search results or hospitals list
                if showingSearchResults {
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(mapItems, id: \.self) { item in
                                Button(action: {
                                    addHospitalFromMapItem(item)
                                    showingSearchResults = false
                                }) {
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text(item.name ?? "Unknown Hospital")
                                            .font(.headline)

                                        if let address = item.placemark.thoroughfare {
                                            Text(address)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }

                                        Divider()
                                    }
                                    .padding(.vertical, 8)
                                    .padding(.horizontal)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color(.systemBackground))
                                }
                            }
                        }
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                        .shadow(radius: 2)
                        .padding(.horizontal)
                    }
                    .frame(height: 300)
                } else {
                    Spacer()
                }

                // Bottom toolbar
                HStack(spacing: 20) {
                    Button(action: {
                        centerMapOnUserLocation()
                    }) {
                        VStack {
                            Image(systemName: "location.fill")
                                .font(.system(size: 22))
                            Text("My Location")
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                        .shadow(radius: 2)
                    }

                    Button(action: {
                        findNearbyHospitals()
                    }) {
                        VStack {
                            Image(systemName: "cross.fill")
                                .font(.system(size: 22))
                            Text("Find Hospitals")
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                        .shadow(radius: 2)
                    }

                    Button(action: {
                        callEmergency()
                    }) {
                        VStack {
                            Image(systemName: "phone.fill")
                                .font(.system(size: 22))
                                .foregroundColor(.red)
                            Text("Emergency")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                        .shadow(radius: 2)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Nearby Hospitals")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedHospital) { hospital in
            HospitalDetailView(hospital: hospital)
        }
        .onAppear {
            checkLocationAuthorization()
        }
    }

    // Search for hospitals using MKLocalSearch
    func searchHospitals() {
        isSearching = true
        showingSearchResults = true

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText + " hospital"
        request.region = region

        let search = MKLocalSearch(request: request)
        search.start { response, error in
            isSearching = false

            guard let response = response, error == nil else {
                print("Error searching for locations: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            self.mapItems = response.mapItems

            // Update map region to show results if we have any
            if let firstItem = response.mapItems.first?.placemark.coordinate {
                withAnimation {
                    region = MKCoordinateRegion(
                        center: firstItem,
                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    )
                }
            }
        }
    }

    // Add a hospital from map search results
    func addHospitalFromMapItem(_ item: MKMapItem) {
        let coordinate = item.placemark.coordinate
        let name = item.name ?? "Unknown Hospital"
        let address = [
            item.placemark.thoroughfare,
            item.placemark.locality,
            item.placemark.administrativeArea,
            item.placemark.postalCode
        ].compactMap { $0 }.joined(separator: ", ")

        // Calculate distance from user location
        let distance: Double
        if let userLocation = locationManager.location {
            let itemLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            distance = userLocation.distance(from: itemLocation) / 1000 // Convert to km
        } else {
            distance = 0
        }

        let hospital = Hospital(
            id: UUID(),
            name: name,
            address: address,
            distance: distance,
            coordinates: coordinate,
            phone: item.phoneNumber ?? "Unknown",
            rating: Double.random(in: 3.5...5.0) // Simulated rating
        )

        // Add to list and select it
        appState.nearbyHospitals.append(hospital)
        selectedHospital = hospital

        // Update region to focus on the selected hospital
        withAnimation {
            region = MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        }
    }

    // Find hospitals near the user's location
    func findNearbyHospitals() {
        guard let userLocation = locationManager.location else {
            checkLocationAuthorization()
            return
        }

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "hospital"
        request.region = MKCoordinateRegion(
            center: userLocation.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )

        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response, error == nil else {
                print("Error searching for hospitals: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            // Convert search results to Hospital objects
            var hospitals: [Hospital] = []

            for item in response.mapItems {
                let coordinate = item.placemark.coordinate
                let name = item.name ?? "Unknown Hospital"
                let address = [
                    item.placemark.thoroughfare,
                    item.placemark.locality,
                    item.placemark.administrativeArea,
                    item.placemark.postalCode
                ].compactMap { $0 }.joined(separator: ", ")

                // Calculate distance from user location
                let itemLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                let distance = userLocation.distance(from: itemLocation) / 1000 // Convert to km

                let hospital = Hospital(
                    id: UUID(),
                    name: name,
                    address: address,
                    distance: distance,
                    coordinates: coordinate,
                    phone: item.phoneNumber ?? "Unknown",
                    rating: Double.random(in: 3.5...5.0) // Simulated rating
                )

                hospitals.append(hospital)
            }

            // Sort by distance and update the app state
            appState.nearbyHospitals = hospitals.sorted(by: { $0.distance < $1.distance })
        }
    }

    // Center the map on user's location
    func centerMapOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            withAnimation {
                region = MKCoordinateRegion(
                    center: location,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
            }
        } else {
            checkLocationAuthorization()
        }
    }

    // Check and request location authorization if needed
    func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            // Show alert to open settings
            print("Location access denied")
        case .authorizedWhenInUse, .authorizedAlways:
            if let location = locationManager.location?.coordinate {
                region = MKCoordinateRegion(
                    center: location,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
            }
        @unknown default:
            break
        }
    }

    // Call emergency services
    func callEmergency() {
        let alert = UIAlertController(
            title: "Emergency",
            message: "Call emergency services (911)?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Call 911", style: .destructive) { _ in
            guard let url = URL(string: "tel:911") else { return }
            UIApplication.shared.open(url)
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        // Present the alert
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(alert, animated: true)
        }
    }
}

// Location Manager to handle location services
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var location: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus

    override init() {
        authorizationStatus = locationManager.authorizationStatus

        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }

    func requestWhenInUseAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.location = location
    }
}

struct HospitalDetailView: View {
    let hospital: Hospital
    @Environment(\.presentationMode) var presentationMode
    @State private var region: MKCoordinateRegion
    @State private var route: MKRoute?
    @State private var routeDistance: Double?
    @State private var routeTime: TimeInterval?
    @State private var isLoadingRoute = false

    init(hospital: Hospital) {
        self.hospital = hospital
        _region = State(initialValue: MKCoordinateRegion(
            center: hospital.coordinates,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Map with directions
                    ZStack {
                        Map(coordinateRegion: $region, annotationItems: [hospital]) { hospital in
                            MapAnnotation(coordinate: hospital.coordinates) {
                                Image(systemName: "cross.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                                    .background(Circle().fill(Color.red).frame(width: 36, height: 36))
                            }
                        }
                        .frame(height: 250)
                        .cornerRadius(10)

                        if isLoadingRoute {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .scaleEffect(1.5)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color.black.opacity(0.2))
                        }

                        // Overlay for route info if available
                        if let distance = routeDistance, let time = routeTime {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Distance: \(String(format: "%.1f", distance)) km")
                                    .font(.caption)
                                Text("Time: \(formatRouteTime(time))")
                                    .font(.caption)
                            }
                            .padding(8)
                            .background(Color(.systemBackground).opacity(0.8))
                            .cornerRadius(8)
                            .padding(10)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                        }
                    }

                    // Hospital details
                    VStack(alignment: .leading, spacing: 10) {
                        Text(hospital.name)
                            .font(.title2)
                            .fontWeight(.bold)

                        HStack {
                            ForEach(0..<5) { index in
                                Image(systemName: index < Int(hospital.rating) ? "star.fill" : "star")
                                    .foregroundColor(.yellow)
                            }

                            Text(String(format: "%.1f", hospital.rating))
                                .foregroundColor(.secondary)
                        }

                        HStack {
                            Image(systemName: "location.fill")
                                .foregroundColor(.red)
                            Text(hospital.address)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.top, 5)

                        HStack {
                            Image(systemName: "phone.fill")
                                .foregroundColor(.green)
                            Text(hospital.phone)
                        }

                        Text("Distance: \(String(format: "%.1f km", hospital.distance))")
                            .padding(.top, 5)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)

                    // Action buttons
                    VStack(spacing: 15) {
                        Button(action: {
                            // Call hospital
                            let tel = "tel://\(hospital.phone.replacingOccurrences(of: "-", with: ""))"
                            guard let url = URL(string: tel) else { return }
                            UIApplication.shared.open(url)
                        }) {
                            HStack {
                                Image(systemName: "phone.fill")
                                Text("Call Hospital")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }

                        Button(action: {
                            calculateRoute()
                        }) {
                            HStack {
                                Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                                Text("Get Directions")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }

                        Button(action: {
                            // Open in Maps app
                            let coordinates = hospital.coordinates
                            let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinates))
                            mapItem.name = hospital.name
                            mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
                        }) {
                            HStack {
                                Image(systemName: "map.fill")
                                Text("Open in Maps")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray4))
                            .foregroundColor(.primary)
                            .cornerRadius(10)
                        }
                    }
                    .padding()

                    // Services
                    VStack(alignment: .leading) {
                        Text("Services")
                            .font(.headline)
                            .padding(.bottom, 5)

                        ForEach(hospitalServices, id: \.self) { service in
                            HStack(alignment: .top) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .padding(.top, 2)
                                Text(service)
                            }
                            .padding(.vertical, 3)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)

                    // Hours
                    VStack(alignment: .leading) {
                        Text("Hours")
                            .font(.headline)
                            .padding(.bottom, 5)

                        if isEmergencyHospital(hospital) {
                            Text("Emergency Services: Open 24/7")
                                .padding(.vertical, 3)
                        }

                        VStack(alignment: .leading, spacing: 5) {
                            ForEach(hospitalHours, id: \.day) { hour in
                                HStack {
                                    Text(hour.day)
                                        .frame(width: 100, alignment: .leading)
                                    Text(hour.hours)
                                }
                                .padding(.vertical, 2)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                .padding()
            }
            .navigationTitle("Hospital Details")
            .navigationBarItems(trailing: Button("Close") {
                presentationMode.wrappedValue.dismiss()
            })
            .onAppear {
                calculateRoute()
            }
        }
    }

    // Calculate route from user location to hospital
    func calculateRoute() {
        let locationManager = CLLocationManager()

//        guard CLLocationManager.locationServicesEnabled() else {
//            return
//        }

        guard let userLocation = locationManager.location?.coordinate else {
            return
        }

        isLoadingRoute = true

        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: userLocation))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: hospital.coordinates))
        request.transportType = .automobile

        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            isLoadingRoute = false

            guard let route = response?.routes.first, error == nil else {
                print("Error calculating route: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            self.route = route
            self.routeDistance = route.distance / 1000 // Convert to km
            self.routeTime = route.expectedTravelTime

            // Adjust region to show the route
            let rect = route.polyline.boundingMapRect
            self.region = MKCoordinateRegion(rect)
        }
    }

    // Format route time
    func formatRouteTime(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes) min"
        }
    }

    // Determine if hospital likely has emergency services
    func isEmergencyHospital(_ hospital: Hospital) -> Bool {
        return hospital.name.lowercased().contains("emergency") ||
               hospital.name.lowercased().contains("general") ||
               hospital.name.lowercased().contains("medical center") ||
               hospital.name.lowercased().contains("memorial")
    }

    // Sample hospital services
    let hospitalServices = [
        "Emergency Care",
        "General Medicine",
        "Cardiology",
        "Pediatrics",
        "Orthopedics",
        "Radiology",
        "Laboratory Services",
        "Pharmacy"
    ]

    // Sample hospital hours
    let hospitalHours = [
        HospitalHours(day: "Monday", hours: "8:00 AM - 6:00 PM"),
        HospitalHours(day: "Tuesday", hours: "8:00 AM - 6:00 PM"),
        HospitalHours(day: "Wednesday", hours: "8:00 AM - 6:00 PM"),
        HospitalHours(day: "Thursday", hours: "8:00 AM - 6:00 PM"),
        HospitalHours(day: "Friday", hours: "8:00 AM - 6:00 PM"),
        HospitalHours(day: "Saturday", hours: "9:00 AM - 4:00 PM"),
        HospitalHours(day: "Sunday", hours: "9:00 AM - 1:00 PM")
    ]
}

struct HospitalHours: Identifiable {
    let id = UUID()
    let day: String
    let hours: String
}
