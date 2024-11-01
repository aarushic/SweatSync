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
    
    @State private var profileImage: UIImage? = nil
    @State private var isImagePickerPresented = false
    

    var body: some View {
        NavigationStack {
            VStack() {
                Text("Fill Your Profile")
                    .font(.title)
                    .bold()
                    .foregroundColor(.white)
                    .padding(.top, 40)
  
                //place holder
                VStack {
                    VStack {
                       if let profileImage = profileImage {
                           Image(uiImage: profileImage)
                               .resizable()
                               .scaledToFill()
                               .frame(width: 130, height: 130)
                               .clipShape(Circle())
                               .overlay(Circle().stroke(Color.white, lineWidth: 2))
                       } else {
                           Circle()
                               .fill(Color.gray)
                               .frame(width: 130, height: 130)
                               .overlay(
                                   Image(systemName: "person.circle.fill")
                                       .resizable()
                                       .scaledToFill()
                                       .foregroundColor(.white)
                                       .frame(width: 120, height: 120)
                               )
                       }
                   }
                   .onTapGesture {
                       isImagePickerPresented = true
                   }
                   .padding()
                }
                .frame(maxWidth: .infinity)
                .background(Theme.primaryColor)
                .cornerRadius(0)
                
                //input fields
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Preferred Name")
                            .font(.custom("Poppins-Regular", size: 20))
                            .foregroundColor(.white)
                        
                        TextField("", text: $preferredName)
                            .font(.custom("Poppins-Regular", size: 14))
                            .foregroundColor(.white)
                            .padding()
                            .background(Theme.secondaryColor)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.white, lineWidth: 1.8)
                            )
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                    }
                    .frame(width: 340)

                    VStack(alignment: .leading, spacing: 15) {
                        Text("Bio")
                            .font(.custom("Poppins-Regular", size: 20))
                            .foregroundColor(.white)
                        
                        TextEditor(text: $bio)
                            .font(.custom("Poppins-Regular", size: 14))
                            .lineSpacing(2)
                            .scrollContentBackground(.hidden)
                            .background(Theme.secondaryColor)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.white, lineWidth: 3)
                            )
                            .cornerRadius(15)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                    }
                    .frame(width: 340)
                }
                .padding(.vertical, 40)
                
                //save profile data to firestore
                Button(action: {
                    saveProfile()
                }) {
                    Text("Continue")
                        .frame(width: 250, height: 50)
                        .background(Theme.primaryColor)
                        .foregroundColor(.black)
                        .cornerRadius(25)
                }
                
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

struct ProfilePreviews: PreviewProvider {
    static var previews: some View {
        FillProfileScreen()
    }
}
