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
    @State private var fullName: String = ""
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var errorMessage: String? = nil
    @State private var isShowingOnboarding: Bool = false
    
    @EnvironmentObject var session: SessionManager

    var body: some View {
        NavigationStack {
            VStack() {
                //top part
                HStack {
                    Text("Create Account")
                        .font(.custom(Theme.headingFont, size: 22))
                        .foregroundColor(Theme.primaryColor)
                        .frame(alignment: .center)
                }
                .padding(.bottom, 40)
                .background(Color.black)
                
                //welcome text
                VStack() {
                    Text("Get Started")
                        .font(.custom(Theme.headingFont, size: 26))
                        .bold()
                        .foregroundColor(.white)
                }
                
                //sign up form fields
                VStack() {
                    VStack(spacing: 5) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Full Name")
                                .font(.custom("Poppins-Regular", size: 17))
                                .foregroundColor(Theme.secondaryColor)
                            
                            TextField("", text: $fullName)
                                .font(.custom("Poppins-Regular", size: 14))
                                .foregroundColor(.white)
                                .padding()
                                .background(Theme.secondaryColor)
                                .cornerRadius(10)
                                .textInputAutocapitalization(.never)
                                .disableAutocorrection(true)
                        }
                        .frame(width: 320)
                        .padding(.bottom, 10)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.custom("Poppins-Regular", size: 17))
                                .foregroundColor(Theme.secondaryColor)
                            
                            SecureField("Password", text: $username)
                                .font(.custom("Poppins-Regular", size: 14))
                                .foregroundColor(.white)
                                .padding()
                                .background(Theme.secondaryColor)
                                .cornerRadius(10)
                                .textInputAutocapitalization(.never)
                                .disableAutocorrection(true)
                        }
                        .frame(width: 320)
                        .padding(.bottom, 10)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.custom("Poppins-Regular", size: 17))
                                .foregroundColor(Theme.secondaryColor)
                            
                            SecureField("Password", text: $password)
                                .font(.custom("Poppins-Regular", size: 14))
                                .foregroundColor(.white)
                                .padding()
                                .background(Theme.secondaryColor)
                                .cornerRadius(10)
                                .textInputAutocapitalization(.never)
                                .disableAutocorrection(true)
                        }
                        .frame(width: 320)
                        .padding(.bottom, 10)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Confirm Password")
                                .font(.custom("Poppins-Regular", size: 17))
                                .foregroundColor(Theme.secondaryColor)
                            
                            SecureField("Password", text: $confirmPassword)
                                .font(.custom("Poppins-Regular", size: 14))
                                .foregroundColor(.white)
                                .padding()
                                .background(Theme.secondaryColor)
                                .cornerRadius(10)
                                .textInputAutocapitalization(.never)
                                .disableAutocorrection(true)
                        }
                        .frame(width: 320)
                        .padding(.bottom, 10)
                    }
                    .padding(.vertical, 30)
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: .infinity)
                    .background(Theme.primaryColor)
                    .cornerRadius(0)
                }
                .edgesIgnoringSafeArea(.horizontal)
                .padding(.vertical, 20)
                
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
        guard !fullName.isEmpty, !username.isEmpty, !password.isEmpty else {
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
                    "fullName": fullName,
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
 

struct Previews: PreviewProvider {
    static var previews: some View {
        SignUpScreen()
    }
}
