//
//  FillProfileScreen.swift
//  sweatsync
//
//  Created by aarushi chitagi on 10/14/24.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct FillProfileScreen: View {
    @State private var preferredName: String = ""
    @State private var bio: String = ""
    @State private var errorMessage: String? = nil  
    @State private var isProfileSaved: Bool = false 
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                
                Text("Fill Your Profile")
                    .font(.title)
                    .bold()
                    .foregroundColor(.white)
                    .padding(.top, 20)
                
                //place holder
                Circle()
                    .fill(Color(red: 208/255, green: 247/255, blue: 147/255))
                    .frame(width: 100, height: 100)
                    .overlay(
                        Image(systemName: "person.circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.gray)
                    )
                    .padding(.bottom, 20)
                
                //input fields
                VStack(spacing: 20) {
                    TextField(
                        "Preferred name",
                        text: $preferredName
                    )
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .textFieldStyle(.roundedBorder)
                    
                    TextField(
                        "Bio",
                        text: $bio
                    )
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .textFieldStyle(.roundedBorder)
                }
                .padding()
                .background(Color(red: 208/255, green: 247/255, blue: 147/255))
                .cornerRadius(15)
                .padding(.horizontal, 30)
                
                //save profile data to firestore
                Button(action: {
                    saveProfile()
                }) {
                    Text("Save Profile")
                        .frame(width: 250, height: 50)
                        .background(Color(red: 208/255, green: 247/255, blue: 147/255))
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
            .fullScreenCover(isPresented: $isProfileSaved) {
                CompleteProfileScreen()
            }
        }
    }
    
    private func saveProfile() {
        guard let user = Auth.auth().currentUser else {
            errorMessage = "Unable to retrieve user. Please log in again."
            return
        }
        
        //check fields
        guard !preferredName.isEmpty, !bio.isEmpty else {
            errorMessage = "Please fill in all fields."
            return
        }
        
        let db = Firestore.firestore()
        
        //user profile data
        let userProfileData: [String: Any] = [
            "preferredName": preferredName,
            "bio": bio,
            "email": user.email ?? "",
            "uid": user.uid
        ]
        
        //save profile data in the "users" collection
        db.collection("users").document(user.uid).setData(userProfileData) { err in
            if let err = err {
                errorMessage = "Error saving profile: \(err.localizedDescription)"
            } else {
                errorMessage = nil
                isProfileSaved = true
            }
        }
    }
}

#Preview {
    FillProfileScreen()
}
