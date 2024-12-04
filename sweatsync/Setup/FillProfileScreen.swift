//
//  FillProfileScreen.swift
//  sweatsync
//
//  Created by aarushi chitagi on 10/14/24.
//
import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import PhotosUI

struct FillProfileScreen: View {
    @State private var preferredName: String = ""
    @State private var bio: String = ""
    @State private var errorMessage: String? = nil
    @State private var isProfileSaved: Bool = false
    
    @State private var profileImage: UIImage? = nil
    @State private var isImagePickerPresented = false
    @State private var selectedImageItem: PhotosPickerItem? = nil
    
    var body: some View {
        NavigationStack {
                VStack {
                    //Header
                    Text("Fill Your Profile")
                        .font(.custom(Theme.bodyFont, size: 24))
                        .bold()
                        .foregroundColor(.white)
                        .padding(.top, 40)
                    
                    //Profile Image Section
                    VStack(spacing: 10) {
                        ZStack(alignment: .bottomTrailing) {
                            if let profileImage = profileImage {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 100, height: 130)
                                    .overlay(
                                        Image(uiImage: profileImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 100)
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(.white, lineWidth: 2))
                                    )
                                    .onTapGesture {
                                        isImagePickerPresented = true
                                    }
                            } else {
                                Circle()
                                    .fill(Color.gray)
                                    .frame(width: 100, height: 130)
                                    .overlay(
                                        Image(systemName: "person.circle.fill")
                                            .resizable()
                                            .scaledToFill()
                                            .foregroundColor(Theme.secondaryColor)
                                            .frame(width: 100, height: 100)
                                    )
                                    .onTapGesture {
                                        isImagePickerPresented = true
                                    }
                            }
                            
                            //Edit icon overlay
                            Circle()
                                .fill(Theme.secondaryColorOp)
                                .frame(width: 35, height: 35)
                                .overlay(
                                    Image(systemName: "plus")
                                        .resizable()
                                        .foregroundColor(Theme.primaryColor)
                                        .frame(width: 18, height: 18)
                                )
                                .offset(x: 0, y: -10)
                                .shadow(radius: 2)
                                .onTapGesture {
                                    isImagePickerPresented = true
                                }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .background(Theme.primaryColor)
                    .padding()
                    
                    // Input Fields for Preferred Name and Bio
                    VStack(spacing: 20) {
                        // Preferred Name Field
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Preferred Name")
                                .font(.custom(Theme.bodyFont, size: 20))
                                .foregroundColor(.white)
                            
                            TextField("", text: $preferredName)
                                .font(.custom(Theme.bodyFont, size: 14))
                                .foregroundColor(.white)
                                .padding()
                                .background(Theme.secondaryColor)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Theme.secondaryColor, lineWidth: 1.8)
                                )
                                .cornerRadius(15)
                                .textInputAutocapitalization(.never)
                                .disableAutocorrection(true)
                                .onSubmit {
                                    dismissKeyboard()
                                }
                        }
                        .frame(width: 340)
                        
                        //Bio Field
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Bio")
                                .font(.custom(Theme.bodyFont, size: 20))
                                .foregroundColor(.white)
                            
                            TextEditor(text: $bio)
                                .font(.custom(Theme.bodyFont, size: 14))
                                .lineSpacing(2)
                                .scrollContentBackground(.hidden)
                                .background(Theme.secondaryColor)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Theme.secondaryColor, lineWidth: 3)
                                )
                                .cornerRadius(15)
                                .textInputAutocapitalization(.never)
                                .disableAutocorrection(true)
                                .foregroundColor(.white)
                                .onSubmit {
                                    dismissKeyboard()
                                }
                        }
                        .frame(width: 340)
                    }
                    .padding(.vertical, 40)
                    
                    // Save Profile Button
                    Button(action: {
                        saveProfile()
                    }) {
                        Text("Continue")
                            .font(.custom(Theme.bodyFont, size: 18))
                            .frame(width: 250, height: 50)
                            .background(Theme.primaryColor)
                            .foregroundColor(.black)
                            .cornerRadius(25)
                    }
                    
                    // Display error message if exists
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .font(.custom(Theme.bodyFont, size: 14))
                            .foregroundColor(.red)
                            .padding(.top, 10)
                    }
                    
                    Spacer()
                }
            .background(Color.black.ignoresSafeArea())
            .photosPicker(isPresented: $isImagePickerPresented, selection: $selectedImageItem, matching: .images)
            .onChange(of: selectedImageItem) { newItem in
                Task {
                    if let newItem = newItem {
                        if let data = try? await newItem.loadTransferable(type: Data.self) {
                            self.profileImage = UIImage(data: data)
                        }
                    }
                }
            }
            .fullScreenCover(isPresented: $isProfileSaved) {
                CompleteProfileScreen()
            }
            .onTapGesture {
                dismissKeyboard()
            }
        }
    }

    private func saveProfile() {
        guard let user = Auth.auth().currentUser else {
            errorMessage = "Unable to retrieve user. Please log in again."
            return
        }

        // Check for required fields
        guard !preferredName.isEmpty, !bio.isEmpty else {
            errorMessage = "Please fill in all fields."
            return
        }
        
        guard profileImage != nil else {
            errorMessage = "Please select a profile image."
            return
        }

        if let profileImage = profileImage {
            let profileImageData = profileImage.jpegData(compressionQuality: 0.5)?.base64EncodedString() ?? ""
            saveProfileData(profileImageBase64: profileImageData)
        } else {
            saveProfileData(profileImageBase64: nil)
        }
    }

    private func saveProfileData(profileImageBase64: String?) {
        guard let user = Auth.auth().currentUser else {
            errorMessage = "User not found."
            return
        }

        let db = Firestore.firestore()
        var userProfileData: [String: Any] = [
            "preferredName": preferredName,
            "bio": bio,
            "email": user.email ?? "",
            "uid": user.uid
        ]

        if let base64Image = profileImageBase64 {
            userProfileData["profileImageBase64"] = base64Image
        }

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
