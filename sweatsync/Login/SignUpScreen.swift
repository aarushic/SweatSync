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
    @State private var isShowingLoginScreen: Bool = false
    @State private var isShowingOnboarding: Bool = false
    
    @EnvironmentObject var session: SessionManager

    var body: some View {
            VStack() {
                //top part
                HStack {
                    Text("Create Account")
                        .font(.custom(Theme.headingFont, size: 22))
                        .foregroundColor(Theme.primaryColor)
                        .frame(alignment: .center)
                }
                .padding(.vertical, 30)
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
                    VStack(spacing: 2) {
                        VStack(alignment: .leading) {
                            Text("Full Name")
                                .font(.custom(Theme.headingFont2, size: 19))
                                .foregroundColor(Theme.secondaryColor)
                            
                            TextField("", text: $fullName)
                                .font(.custom(Theme.headingFont2, size: 19))
                                .foregroundColor(.white)
                                .padding()
                                .background(Theme.secondaryColor)
                                .cornerRadius(10)
                                .textInputAutocapitalization(.never)
                                .disableAutocorrection(true)
                                .onSubmit {
                                    dismissKeyboard()
                                }
                        }
                        .frame(width: 320)
                        .padding(.vertical, 20)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.custom(Theme.headingFont2, size: 19))
                                .foregroundColor(Theme.secondaryColor)
                            
                            TextField("", text: $username)
                                .font(.custom(Theme.headingFont2, size: 19))
                                .foregroundColor(.white)
                                .padding()
                                .background(Theme.secondaryColor)
                                .cornerRadius(10)
                                .textInputAutocapitalization(.never)
                                .disableAutocorrection(true)
                                .onSubmit {
                                    dismissKeyboard()
                                }
                        }
                        .frame(width: 320)
                        .padding(.bottom, 20)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.custom(Theme.headingFont2, size: 19))
                                .foregroundColor(Theme.secondaryColor)
                            
                            SecureField("", text: $password)
                                .font(.custom(Theme.headingFont2, size: 19))
                                .foregroundColor(.white)
                                .padding()
                                .background(Theme.secondaryColor)
                                .cornerRadius(10)
                                .textInputAutocapitalization(.never)
                                .disableAutocorrection(true)
                                .onSubmit {
                                    dismissKeyboard()
                                }
                        }
                        .frame(width: 320)
                        .padding(.bottom, 20)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Confirm Password")
                                .font(.custom(Theme.headingFont2, size: 19))
                                .foregroundColor(Theme.secondaryColor)
                            
                            SecureField("", text: $confirmPassword)
                                .font(.custom(Theme.headingFont2, size: 19))
                                .foregroundColor(.white)
                                .padding()
                                .background(Theme.secondaryColor)
                                .cornerRadius(10)
                                .textInputAutocapitalization(.never)
                                .disableAutocorrection(true)
                                .onSubmit {
                                    dismissKeyboard()
                                }
                        }
                        .frame(width: 320)
                        .padding(.bottom, 20)
                    }
                    .frame(maxWidth: .infinity)
                    .background(Theme.primaryColor)
                }
                .edgesIgnoringSafeArea(.horizontal)
                .padding(.top, 20)
                .padding(.bottom, 70)
                
                //sign up button
                Button(action: {
                    createUser()
                }) {
                    Text("Sign Up")
                        .frame(width: 200, height: 50)
                        .font(.custom(Theme.headingFont2, size: 19))
                        .background(Theme.secondaryColor)
                        .cornerRadius(25)
                        .foregroundColor(fullName.isEmpty || username.isEmpty || password.isEmpty || confirmPassword.isEmpty ? Color.gray : Color.white)
                }
                .disabled(fullName.isEmpty || username.isEmpty || password.isEmpty || confirmPassword.isEmpty)
                .padding(.top, -50)
                
                //error message
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.top, 10)
                }
                
                Spacer()
                
                //already have an account
                HStack {
                    Text("Already have an account?")
                        .font(.custom(Theme.bodyFont, size: 16))
                        .foregroundColor(.white)
                    Button(action: {
                        isShowingLoginScreen = true
                    }) {
                        Text("Log In")
                            .foregroundColor(Theme.primaryColor)
                            .font(.custom(Theme.bodyFont, size: 16))
                    }
                }

            }
            .background(Color.black.ignoresSafeArea())
            .onTapGesture {
                dismissKeyboard()
            }
            .fullScreenCover(isPresented: $isShowingOnboarding) {
                FillProfileScreen()
            }
            .fullScreenCover(isPresented: $isShowingLoginScreen) {
                LoginScreen()
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
                    "uid": uid,
                    "notificationsEnabled": true,
                    "commentsDisabled": false
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
