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
    @State private var age: Int = 0
    @State private var height: Int = 0
    @State private var weight: Int = 0
    @State private var errorMessage: String? = nil
    @State private var isProfileCompleted: Bool = false
    
    @EnvironmentObject var session: SessionManager

    var body: some View {
        NavigationStack {
            
            VStack(spacing: 20) {
                HStack {
                    Button(action: {
                        // Handle back action
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(Color(red: 208/255, green: 247/255, blue: 147/255))
                    }
                    Spacer()
                    Text("Back")
                        .foregroundColor(Color(red: 208/255, green: 247/255, blue: 147/255))
                }
                .padding()
                .background(Color.black)
                
                //input fields
                VStack(spacing: 20) {
            
                    //age picker
                    HStack {
                        Text("Age")
                            .font(.headline)
                            .foregroundColor(Theme.secondaryColor)
                        Spacer()
                        Picker("Height", selection: $age) {
                            ForEach(12...100, id: \.self) { age in
                                Text("\(age)").tag(age)
                            }
                        }
                        .frame(width: 100, height: 80)
                        .clipped()
                        .labelsHidden()
                        .background(Theme.secondaryColor)
                        .cornerRadius(10)
                    }
                
                    //height picker
                    HStack {
                        Text("Height (cm)")
                            .font(.headline)
                            .foregroundColor(Theme.secondaryColor)
                        Spacer()
                        Picker("Height", selection: $height) {
                            ForEach(48...84, id: \.self) { height in
                                Text("\(height) in").tag(height)
                            }
                        }
                        .frame(width: 100, height: 80)
                        .clipped()
                        .labelsHidden()
                        .background(Theme.secondaryColor)
                        .cornerRadius(10)
                    }
                    
                    //weight picker
                    HStack {
                        Text("Weight (lb)")
                            .font(.headline)
                            .foregroundColor(Theme.secondaryColor)
                        Spacer()
                        Picker("Weight", selection: $weight) {
                            ForEach(50...300, id: \.self) { weight in
                                Text("\(weight) lb").tag(weight)
                            }
                        }
                        .frame(width: 100, height: 80)
                        .clipped()
                        .labelsHidden()
                        .background(Theme.secondaryColor)
                        .cornerRadius(10)
                    }
        
                }
                .padding()
                .background(Theme.primaryColor)
                .cornerRadius(15)
                .padding(.horizontal, 30)
                
                //omplete profile
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
        //check user is authenticated
        guard let user = Auth.auth().currentUser else {
            errorMessage = "Unable to retrieve user. Please log in again."
            return
        }
        
        //check fields are not empty
        guard age != 0, height != 0, weight != 0 else {
            errorMessage = "Please fill in all fields."
            return
        }
        
        let db = Firestore.firestore()
        
        let additionalProfileData: [String: Any] = [
            "age": age,
            "height": height,
            "weight": weight,
        ]
        
        //finish existing profile data for the user
        db.collection("users").document(user.uid).updateData(additionalProfileData) { err in
            if let err = err {
                errorMessage = "error \(err.localizedDescription)"
            } else {
                errorMessage = nil
                isProfileCompleted = true
                print("Profile successfully updated")
            }
        }
        
        session.signIn()
    }
}

#Preview {
    CompleteProfileScreen()
}
