import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var viewModel = MapViewModel()
    @State private var searchText = ""
    @State private var selectedLocation: MapLocation?
    @State private var showSheet = false
    
    var body: some View {
        ZStack(alignment: .top) {
            // Map View
            Map(coordinateRegion: $locationManager.region,
                showsUserLocation: true,
                annotationItems: viewModel.locations + [locationManager.currentLocation].compactMap { $0 }) { location in
                MapAnnotation(coordinate: location.coordinate) {
                    // Different markers for current location vs search results
                    if location.isCurrentLocation {
                        CurrentLocationMarker()
                    } else {
                        LocationMarker(
                            isSelected: selectedLocation?.id == location.id,
                            title: location.name
                        )
                        .onTapGesture {
                            selectedLocation = location
                            showSheet = true
                        }
                    }
                }
            }
            .edgesIgnoringSafeArea(.all)
            
            // Current Location Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        locationManager.centerOnUserLocation()
                    }) {
                        Image(systemName: "location.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.blue)
                            .background(Circle().fill(Color.white))
                            .shadow(radius: 4)
                    }
                    .padding()
                }
            }
            
            // Search UI
            VStack(spacing: 0) {
                HStack {
                    TextField("Search places...", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                    
                    Button(action: {
                        performSearch()
                    }) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.blue)
                            .clipShape(Circle())
                    }
                }
                .padding()
                .background(Color.white)
                .shadow(radius: 5)
                
                if !viewModel.locations.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(viewModel.locations) { location in
                                LocationCard(location: location) {
                                    locationManager.setRegion(to: location.coordinate)
                                    selectedLocation = location
                                    showSheet = true
                                }
                            }
                        }
                        .padding()
                    }
                    .background(Color.white.opacity(0.8))
                }
            }
        }
        .sheet(isPresented: $showSheet) {
            if let location = selectedLocation {
                LocationDetailSheet(location: location,
                                  userLocation: locationManager.region.center)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
        }
    }
    
    private func performSearch() {
        viewModel.searchLocations(searchText: searchText, region: locationManager.region)
    }
}

// Current Location Marker
struct CurrentLocationMarker: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 40, height: 40)
            
            Circle()
                .fill(Color.white)
                .frame(width: 20, height: 20)
            
            Circle()
                .fill(Color.blue)
                .frame(width: 16, height: 16)
        }
    }
}

// Location Pin Marker
struct LocationMarker: View {
    let isSelected: Bool
    let title: String
    
    var body: some View {
        VStack {
            Image(systemName: "mappin.circle.fill")
                .font(.title)
                .foregroundColor(.red)
                .scaleEffect(isSelected ? 1.3 : 1.0)
                .animation(.spring(), value: isSelected)
            
            Text(title)
                .font(.caption)
                .padding(4)
                .background(Color.white)
                .cornerRadius(4)
                .opacity(isSelected ? 1 : 0)
        }
    }
}

// Extended MapLocation
struct MapLocation: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
    var distance: Double?
    var isCurrentLocation: Bool = false
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 22.5726, longitude: 88.3639), // Kolkata
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @Published var currentLocation: MapLocation?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        manager.stopUpdatingLocation()
        
        currentLocation = MapLocation(
            name: "My Location",
            coordinate: location.coordinate,
            isCurrentLocation: true
        )
        
        setRegion(to: location.coordinate)
    }
    
    func setRegion(to coordinate: CLLocationCoordinate2D) {
        withAnimation {
            region = MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
        }
    }
    
    func centerOnUserLocation() {
        if let location = currentLocation {
            setRegion(to: location.coordinate)
        } else {
            manager.requestLocation()
        }
    }
}

// Rest of the code remains the same (LocationCard, LocationDetailSheet, MapViewModel)
struct LocationCard: View {
    let location: MapLocation
    let action: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(location.name)
                .font(.headline)
            if let distance = location.distance {
                Text(String(format: "%.1f km away", distance))
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 3)
        .onTapGesture(perform: action)
    }
}

struct LocationDetailSheet: View {
    let location: MapLocation
    let userLocation: CLLocationCoordinate2D
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading) {
                    Text(location.name)
                        .font(.title2)
                        .bold()
                    
                    if let distance = location.distance {
                        Text(String(format: "%.1f kilometers away", distance))
                            .foregroundColor(.gray)
                    }
                }
                Spacer()
                
                Button(action: {
                    openInMaps()
                }) {
                    Image(systemName: "arrow.triangle.turn.up.right.circle.fill")
                        .font(.title)
                        .foregroundColor(.blue)
                }
            }
            
            Divider()
            
            Button(action: openInMaps) {
                HStack {
                    Image(systemName: "map.fill")
                    Text("Get Directions")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            
            Spacer()
        }
        .padding()
        .background(
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    dismiss()
                }
        )
    }
    
    private func openInMaps() {
        let destination = MKMapItem(placemark: MKPlacemark(coordinate: location.coordinate))
        destination.name = location.name
        
        MKMapItem.openMaps(
            with: [destination],
            launchOptions: [
                MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
            ]
        )
    }
}

class MapViewModel: ObservableObject {
    @Published var locations: [MapLocation] = []
    
    func searchLocations(searchText: String, region: MKCoordinateRegion) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.region = region
        
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            guard let self = self,
                  let response = response,
                  error == nil else {
                print("Search error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            let locations = response.mapItems.map { item -> MapLocation in
                let distance = item.placemark.location?.distance(from: CLLocation(latitude: region.center.latitude, longitude: region.center.longitude)) ?? 0
                return MapLocation(
                    name: item.name ?? "Unknown location",
                    coordinate: item.placemark.coordinate,
                    distance: distance / 1000 // Convert to kilometers
                )
            }
            
            DispatchQueue.main.async {
                self.locations = locations
            }
        }
    }
}

#Preview {
    ContentView()
}
