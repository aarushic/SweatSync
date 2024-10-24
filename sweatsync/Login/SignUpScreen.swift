//
//  SignUpScreen.swift
//  sweatsync
//
//  Created by aarushi chitagi on 10/14/24.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct SignUpScreen: View {
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var errorMessage: String? = nil
    @State private var isShowingOnboarding: Bool = false
    
    @EnvironmentObject var session: SessionManager

    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                //top part
                HStack {
                    Text("Sign Up")
                        .font(.headline)
                        .foregroundColor(Theme.primaryColor)
                        .frame(maxWidth: .infinity, alignment: .center)
                    Spacer()
                    Spacer()
                }
                .padding()
                .background(Color.black)
                
                //welcome text
                VStack(spacing: 20) {
                    Text("Get Started")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.white)
                }
                .padding(.bottom, 30)
                
                //sign up form fields
                VStack(spacing: 30) {
                    TextField("First name", text: $firstName)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .textFieldStyle(.roundedBorder)
                    TextField("Last name", text: $lastName)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .textFieldStyle(.roundedBorder)
                    TextField("Username (email address)",text: $username)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .textFieldStyle(.roundedBorder)
                    SecureField("Password", text: $password)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .textFieldStyle(.roundedBorder)
                    SecureField("Confirm password", text: $confirmPassword)
                        .onSubmit {
                            //confirm logic
                        }
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .textFieldStyle(.roundedBorder)
                }
                .padding()
                .background(Theme.primaryColor)
                
                //error message
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.top, 10)
                }
                
                //sign up button
                Button(action: {
                    createUser()
                }) {
                    Text("Sign Up")
                        .frame(width: 200, height: 50)
                        .background(Theme.secondaryColor) 
                        .foregroundColor(.white)
                        .cornerRadius(25)
                }
                
                //google sign up
                Text("or sign up with")
                    .foregroundColor(.white)
                
                Button(action: {
                    //google sign up, do later
                }) {
                    Image(systemName: "g.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.white)
                }
                
                //already have an account
                HStack {
                    Text("Already have an account?")
                        .foregroundColor(.white)
                    NavigationLink {
                        LoginScreen()
                    } label: {
                        Text("Log in").foregroundColor(Theme.primaryColor)
                    }
                }

            }
            .background(Color.black.ignoresSafeArea())
            .fullScreenCover(isPresented: $isShowingOnboarding) {
                FillProfileScreen()
            }
        }
    }

    private func createUser() {
        //check if passwords match
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            return
        }
        
        //check if fields are not empty
        guard !firstName.isEmpty, !lastName.isEmpty, !username.isEmpty, !password.isEmpty else {
            errorMessage = "All fields are required"
            return
        }

        //create the user with firebase auth
        Auth.auth().createUser(withEmail: username, password: password, completion: { result, err in
            if let err = err {
                errorMessage = err.localizedDescription
                return
            }
            
            //success
            errorMessage = nil
            
            //save user info in firestore
            if let uid = result?.user.uid {
                let db = Firestore.firestore()
                db.collection("users").document(uid).setData([
                    "firstName": firstName,
                    "lastName": lastName,
                    "email": username,
                    "uid": uid
                ]) { err in
                    if let err = err {
                        //firestore error
                        errorMessage = "Failed to save user info: \(err.localizedDescription)"
                    } else {
                        print("User information saved successfully")
                    }
                }
            }
            
            //update the session state
            isShowingOnboarding = true
        })
    }
}


#Preview {
    SignUpScreen()
}
