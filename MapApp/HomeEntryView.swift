//
//  HomeEntryView.swift
//  MapApp
//
//  Created by MacMini6 on 24/01/25.
//

import SwiftUI

struct HomeEntryView: View {
    var body: some View {
        
        ZStack{
            Color.green
                .ignoresSafeArea()
            
            NavigationView {
                VStack(spacing: 30) {
                    // Navigate to Map View
                    NavigationLink(destination: MapkitView()) {
                        Text("Go to Map View")
                            .padding()
                            .font(.title)
                            .buttonBorderShape(.roundedRectangle)
                            .background(Color.blue)
                            .tint(.white)
                            .cornerRadius(20)
                    }
                    
                    // Navigate to Map View 2
                    NavigationLink(destination: ContentView()) {
                        Text("Go to Map View 2")
                            .padding()
                            .font(.title)
                            .buttonBorderShape(.roundedRectangle)
                            .background(Color.blue)
                            .tint(.white)
                            .cornerRadius(20)
                    }
                    
                    // Navigate to Login View
                    NavigationLink(destination: LoginSignupView()) {
                        Text("Go to Login View")
                            .padding()
                            .font(.title)
                            .buttonBorderShape(.roundedRectangle)
                            .background(Color.blue)
                            .tint(.white)
                            .cornerRadius(20)
                    }
                    
                }
                .navigationTitle("Home")
            }
        }
    }
}

#Preview {
    HomeEntryView()
}
