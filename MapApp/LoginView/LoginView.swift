//
//  LoginView.swift
//  MapApp
//
//  Created by MacMini6 on 24/01/25.
//

import SwiftUI

struct LoginSignupView: View {
    @State private var selectedSegment: LoginSignupType = .login
    @State private var email = ""
    @State private var password = ""
    @Namespace private var animation // For matched geometry effect
    @State private var showLogin = true // Track which view is currently visible
    
    var body: some View {
        ZStack {
            // White Background
            Color.white
                .ignoresSafeArea()
            
            VStack {
                // Segmented Control (Blue Styling)
                HStack {
                    ForEach(LoginSignupType.allCases, id: \.self) { type in
                        Text(type.rawValue.capitalized)
                            .font(.system(size: 14, weight: .bold)) // Smaller font size
                            .padding(.vertical, 6) // Smaller vertical padding
                            .padding(.horizontal, 12)
                            .frame(maxWidth: .infinity)
                            .background(selectedSegment == type ? Color.blue : Color.clear)
                            .foregroundColor(selectedSegment == type ? .white : .blue)
                            .clipShape(Capsule())
                            .onTapGesture {
                                if selectedSegment != type {
                                    withAnimation(.easeInOut(duration: 0.6)) {
                                        showLogin = (type == .login)
                                        selectedSegment = type
                                    }
                                }
                            }
                    }
                }
                .padding(8)
                .background(
                    Capsule()
                        .stroke(Color.blue, lineWidth: 2)
                )
                .padding(.horizontal, 80)
                .frame(height: 40)
                
                Spacer()
                
                // Switching Form with Slide Animation
                ZStack {
                    if showLogin {
                        formView(for: .login)
                            .transition(.asymmetric(
                                insertion: .move(edge: .leading),
                                removal: .move(edge: .trailing)
                            ))
                    } else {
                        formView(for: .signup)
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing),
                                removal: .move(edge: .leading)
                            ))
                    }
                }
                .frame(height: 100)
                .animation(.easeInOut(duration: 0.6), value: showLogin)
                
                // Button (Blue Style)
                Button(action: {
                    // Handle Login or Sign Up action
                    print("\(selectedSegment.rawValue.capitalized) tapped.")
                }) {
                    Text(selectedSegment.rawValue.capitalized)
                        .font(.headline)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .padding(.horizontal, 24)
                }
                .padding(.top, 40)
                
                Spacer()
            }
            .padding(.top, 40)
        }
    }
    
    // Form View for Login/Sign Up
    @ViewBuilder
    private func formView(for type: LoginSignupType) -> some View {
        VStack(spacing: 20) {
            AnimatedField(
                placeholder: "Email",
                text: $email,
                animation: animation
            )
            AnimatedField(
                placeholder: "Password",
                text: $password,
                isSecure: true,
                animation: animation
            )
        }
        .padding(.horizontal, 24)
    }
}

// Enum for Segment Control
enum LoginSignupType: String, CaseIterable {
    case login
    case signup
}

// Reusable Animated TextField
struct AnimatedField: View {
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    let animation: Namespace.ID
    
    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                Text(placeholder)
                    .font(.subheadline)
                    .foregroundColor(.blue) // Blue placeholder text
                    .matchedGeometryEffect(id: placeholder, in: animation)
                    .padding(.leading, 10)
                    .padding(.bottom, 10)
            }
            
            if isSecure {
                SecureField("", text: $text)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(12)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.blue, lineWidth: 1)
                    )
            } else {
                TextField("", text: $text)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(12)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.blue, lineWidth: 1)
                    )
            }
        }
    }
}

#Preview {
    LoginSignupView()
}
