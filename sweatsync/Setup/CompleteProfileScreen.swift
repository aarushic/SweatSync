//
//  CompleteProfileScreen.swift
//  sweatsync
//
//  Created by aarushi chitagi on 10/14/24.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct CompleteProfileScreen: View {
    @State private var age: Int = 12
    @State private var height: Int = 48
    @State private var weight: Int = 50
    @State private var errorMessage: String? = nil
    @State private var isProfileCompleted: Bool = false
    
    @State private var lifting: Bool = false
    @State private var running: Bool = false
    @State private var biking: Bool = false
    @State private var swimming: Bool = false
    @State private var yoga: Bool = false
    @State private var hiking: Bool = false
    
    @EnvironmentObject var session: SessionManager

    var body: some View {
        NavigationStack {
            VStack(spacing: 50) {
                Text("Complete Your Profile")
                    .font(.title)
                    .bold()
                    .foregroundColor(.white)
                    .padding(.top, 40)
                
                //input fields
                VStack(spacing: 20) {
                    //age picker
                    HStack {
                        Text("Age")
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                        Picker("Height", selection: $age) {
                            ForEach(12...100, id: \.self) { age in
                                Text("\(age)").tag(age)
                            }
                        }
                        .frame(width: 200, height: 50)
                        .clipped()
                        .labelsHidden()
                        .background(Theme.secondaryColor)
                        .cornerRadius(10)
                    }
                
                    //height picker
                    HStack {
                        Text("Height (cm)")
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                        Picker("Height", selection: $height) {
                            ForEach(48...84, id: \.self) { height in
                                Text("\(height) in").tag(height)
                            }
                        }
                        .frame(width: 200, height: 50)
                        .clipped()
                        .labelsHidden()
                        .background(Theme.secondaryColor)
                        .cornerRadius(10)
                    }
                    
                    //weight picker
                    HStack {
                        Text("Weight (lb)")
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                        Picker("Weight", selection: $weight) {
                            ForEach(50...300, id: \.self) { weight in
                                Text("\(weight) lb").tag(weight)
                            }
                        }
                        .frame(width: 200, height: 50)
                        .clipped()
                        .labelsHidden()
                        .background(Theme.secondaryColor)
                        .cornerRadius(10)
                    }
                }
                .padding()
                .padding(.horizontal, 20)
                
                //training priorities
                VStack(alignment: .leading) {
                    Text("Training Preferences")
                        .font(.custom("Poppins-Bold", size: 20))
                        .foregroundColor(.white)
                        .padding(.bottom, 10)
                    
                    //grid layout for preferences
                    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
                    
                    LazyVGrid(columns: columns, spacing: 15) {
                        PreferenceToggle(title: "Lifting", isSelected: $lifting)
                        PreferenceToggle(title: "Running", isSelected: $running)
                        PreferenceToggle(title: "Biking", isSelected: $biking)
                        PreferenceToggle(title: "Swimming", isSelected: $swimming)
                        PreferenceToggle(title: "Yoga", isSelected: $yoga)
                        PreferenceToggle(title: "Hiking", isSelected: $hiking)
                    }
                }
                .frame(width: 340)
                .background(Color.black.ignoresSafeArea())
                
                //complete profile
                Button(action: {
                    completeProfile()
                }) {
                    Text("Complete Profile")
                        .frame(width: 250, height: 50)
                        .background(Theme.primaryColor)
                        .foregroundColor(.black)
                        .cornerRadius(25)
                }
                .padding(.top, 20)
                
                //error
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.top, 10)
                }
                Spacer()
            }
            .background(Color.black.ignoresSafeArea())
            .fullScreenCover(isPresented: $isProfileCompleted) {
                OnboardingScreen1()
            }
        }
    }
    
    private func completeProfile() {
        // Check if user is authenticated
        guard let user = Auth.auth().currentUser else {
            errorMessage = "Unable to retrieve user. Please log in again."
            return
        }

        // Check fields are not empty
        guard age != 0, height != 0, weight != 0 else {
            errorMessage = "Please fill in all fields."
            return
        }

        let db = Firestore.firestore()
        
        // Collect selected training priorities
        var trainingPreferences: [String] = []
        if lifting { trainingPreferences.append("Lifting") }
        if running { trainingPreferences.append("Running") }
        if biking { trainingPreferences.append("Biking") }
        if swimming { trainingPreferences.append("Swimming") }
        if yoga { trainingPreferences.append("Yoga") }
        if hiking { trainingPreferences.append("Hiking") }
        
        let additionalProfileData: [String: Any] = [
            "age": age,
            "height": height,
            "weight": weight,
            "trainingPreferences": trainingPreferences
        ]

        // Update profile data in Firebase
        db.collection("users").document(user.uid).updateData(additionalProfileData) { err in
            if let err = err {
                errorMessage = "Error: \(err.localizedDescription)"
            } else {
                errorMessage = nil
                isProfileCompleted = true
                print("Profile successfully updated with training preferences")
            }
        }

        session.signIn()
    }
}

struct PreferenceToggle: View {
    let title: String
    @Binding var isSelected: Bool
    
    var body: some View {
        Button(action: {
            isSelected.toggle()
        }) {
            Text(title)
                .font(.custom("Poppins-Regular", size: 16))
                .foregroundColor(isSelected ? .black : .white)
                .frame(maxWidth: .infinity, minHeight: 50)
                .background(isSelected ? Theme.primaryColor : Theme.secondaryColor)
                .cornerRadius(10)
        }
    }
}

#Preview {
    CompleteProfileScreen()
}
