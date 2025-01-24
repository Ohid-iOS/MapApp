//
//  SwiftUIView.swift
//  MapApp
//
//  Created by MacMini6 on 22/01/25.
//

import SwiftUI
import MapKit
struct LocationDetailsView: View {
    @Binding var selectedPlaceMark: MKMapItem?
    @Binding var show: Bool
    @State private var lookAroundScene: MKLookAroundScene?
    @Binding var getDirections: Bool
    
    var body: some View {
        VStack{
            HStack{
                VStack(alignment: .leading){
                    Text(selectedPlaceMark?.placemark.name ?? "")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text(selectedPlaceMark?.placemark.title ?? "")
                        .font(.footnote)
                        .foregroundStyle(.gray)
                        .lineLimit(2)
                        .padding(.trailing)
                }
                
                Spacer()
                Button {
                    show.toggle()
                    selectedPlaceMark = nil
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(.gray, Color(.systemGray6))
                }
            }
            
            if let scene = lookAroundScene{
                LookAroundPreview(initialScene: scene)
                    .frame(height: 200)
                    .cornerRadius(8)
                    .padding()
            }else{
                ContentUnavailableView("No Preview Available", systemImage: "eye.slash")
            }
            
            HStack(spacing:30){
                Button {
                    if let selectedPlaceMark{
                        selectedPlaceMark.openInMaps()
                    }
                } label: {
                    Text("Open in Maps")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 170, height:40)
                        .background(.green)
                        .cornerRadius(12)
                }
                Button {
                    getDirections = true
                    show = false
                } label: { Text("Get Directions")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 170, height:40)
                        .background(.blue)
                        .cornerRadius(12)
                }
            }
        }.padding()
        .onSubmit {
            fetchLookAroundScene()
        }
        .onChange(of: selectedPlaceMark, { oldValue, newValue in
            fetchLookAroundScene()
        })
    }
}

extension LocationDetailsView{
    func fetchLookAroundScene(){
        if let selectedPlaceMark {
            lookAroundScene = nil
            Task{
                let request = MKLookAroundSceneRequest(mapItem: selectedPlaceMark)
                lookAroundScene = try? await request.scene
            }
        }
    }
}


#Preview {
    LocationDetailsView(selectedPlaceMark: .constant(nil), show: .constant(false), getDirections: .constant(false))
}
