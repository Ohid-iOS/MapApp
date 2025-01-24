////
////  MapkitView.swift
////  MapApp
////
////  Created by MacMini6 on 22/01/25.
////
//


import SwiftUI
import MapKit
struct MapkitView: View {
    
    @State private var cameraPosition: MapCameraPosition = .region(.userRegion)
    @State private var searchLocation = ""
    @State private var results = [MKMapItem]()
    @State private var selectedPlaceMark: MKMapItem? /// for select pin from map
    @State private var showDetails = false
    @State private var getDirections = false
    
    @State private var routeDisplaying = false
    @State private var route: MKRoute?
    @State private var routeDestination: MKMapItem?
    
    var body: some View {
        Map(position: $cameraPosition, selection: $selectedPlaceMark){
            
            Annotation("Tech Exactly", coordinate: .defaultCoordinate) {
                ZStack{
                    Circle()
                        .frame(width:32, height: 32)
                        .foregroundStyle(.red.opacity(0.65))
                    Circle()
                        .frame(width:20, height: 20)
                        .foregroundStyle(.white)
                    Circle()
                        .frame(width:12, height: 12)
                        .foregroundStyle(.blue)
                }
            }
            ForEach(results, id: \.self){ items in
                if routeDisplaying{
                    if items == routeDestination{
                        let placemark = items.placemark
                        Marker(placemark.name ?? "", coordinate: placemark.coordinate )
                    }
                    
                }else{
                    let placemark = items.placemark
                    Marker(placemark.name ?? "", coordinate: placemark.coordinate )
                }
            }
            
            if let route{
                MapPolyline(route.polyline)
                    .stroke(.blue, lineWidth: 6)
            }
            
        }
        .overlay(alignment: .top){
            TextField("Search for a location....", text:$searchLocation)
                .font(.subheadline)
                .padding(12)
                .background(.white)
                .padding()
                .padding(.trailing, 50)
                .shadow(radius: 10)
        }.onSubmit(of: .text) {
            Task{ await searchPlace() }
            
        }.onChange(of: getDirections, { oldValue, newValue in
            if newValue{
                fetchRoute()
            }
        })
        .onChange(of: selectedPlaceMark, { oldValue, newValue in
            showDetails = (newValue != nil)
        })
        .sheet(isPresented: $showDetails, content: {
            LocationDetailsView(selectedPlaceMark: $selectedPlaceMark, show: $showDetails, getDirections: $getDirections)
                .presentationDetents([.height(340)])
                /// for accessing  background map view
                .presentationBackgroundInteraction(.enabled(upThrough: .height(340)))
                .presentationCornerRadius(12)
        })
        
        .mapControls {
            MapCompass()
            MapPitchToggle()
            MapUserLocationButton()
        }
    }
    
    
}

extension MapkitView{
    func searchPlace() async{
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchLocation
        
        let results = try? await MKLocalSearch(request: request).start()
        self.results = results?.mapItems ?? []
    }
    
    func fetchRoute(){
        if let selectedPlaceMark{
            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: .init(coordinate: .defaultCoordinate))
            request.destination = selectedPlaceMark
            
            Task{
                let result = try? await MKDirections(request: request).calculate()
                route = result?.routes.first
                routeDestination = selectedPlaceMark
                
                withAnimation {
                    routeDisplaying = true
                    showDetails = false
                    
                    if let rect = route?.polyline.boundingMapRect, routeDisplaying{
                        cameraPosition = .rect(rect)
                    }
                }
                
            }
            
        }
    }
}
/// MARK: - CLLocationCoordinate2D Extension
extension CLLocationCoordinate2D {
    static var defaultCoordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: 22.5726, longitude: 88.3639) //Kolkata
    }
}
/// MARK: - MKCoordinateRegion Extension
extension MKCoordinateRegion {
    static var userRegion:MKCoordinateRegion{
        return .init(center: .defaultCoordinate, latitudinalMeters: 100000, longitudinalMeters: 100000)
    }
}

#Preview {
    MapkitView()
}
