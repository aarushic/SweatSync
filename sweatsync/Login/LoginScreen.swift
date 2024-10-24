//
//  LoginScreen.swift
//  sweatsync
//
//  Created by aarushi chitagi on 10/14/24.
//

import Foundation
import SwiftUI
import FirebaseAuth

struct LoginScreen: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?
    @State private var isShowingSignUpScreen: Bool = false
    @State private var isShowingHomeScreen: Bool = false
    
    @EnvironmentObject var session: SessionManager

    var body: some View {
        VStack(spacing: 30) {
            //top part
            HStack {
//                Button(action: {
//                    //back action here
//                }) {
//                    Image(systemName: "chevron.left")
//                        .foregroundColor(.white)
//                }
                Text("Log In")
                    .font(.headline)
                    .foregroundColor(Theme.primaryColor)
                    .frame(maxWidth: .infinity, alignment: .center)
                Spacer()
                Spacer()
            }
            .padding()
            .background(Color.black)
            
            //welcome message
            VStack(spacing: 20) {
                Text("Welcome")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
            }
            .padding(.bottom, 30)
            
            //login form fields
            VStack(spacing: 30) {
                TextField("Username (email address)", text: $username)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .textFieldStyle(.roundedBorder)

                SecureField("Password", text: $password)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .textFieldStyle(.roundedBorder)
            }
            .padding()
            .background(Theme.primaryColor)
            
            //log in button
            Button(action: {
                loginUser()
            }) {
                Text("Log In")
                    .frame(width: 200, height: 50)
                    .background(Theme.secondaryColor)
                    .cornerRadius(25)
                    .foregroundColor(username.isEmpty || password.isEmpty ? Color.gray : Color.white)
                    .cornerRadius(25)
            }
            .disabled(username.isEmpty || password.isEmpty)
            .padding(.top, 20)
            
            //error message
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.top, 10)
            }

            //google sign in option
            Text("or sign in with")
                .foregroundColor(.white)
            
            Button(action: {
                // Handle Google sign-in action
            }) {
                Image(systemName: "g.circle.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            //sign up option
            HStack {
                Text("Don't have an account?")
                    .foregroundColor(.white)
                Button(action: {
                    isShowingSignUpScreen = true
                }) {
                    Text("Sign Up")
                        .foregroundColor(Theme.primaryColor)
                }
            }
        }
        .padding(.bottom, 20)
        .background(Color.black.ignoresSafeArea())
        .fullScreenCover(isPresented: $isShowingSignUpScreen) {
            SignUpScreen()
        }
        .fullScreenCover(isPresented: $isShowingHomeScreen) {
            TabBarView()
        }
    }
    
    //firebase login
    private func loginUser() {
        Auth.auth().signIn(withEmail: username, password: password) { result, error in
            if let error = error {
                self.errorMessage = "Login failed: \(error.localizedDescription)"
                return
            }
            print("Successfully logged in with user ID: \(result?.user.uid ?? "")")
            // success
            self.errorMessage = nil
            //update the session state
            session.signOut()
            session.signIn()
            isShowingHomeScreen = true
        }
    }
}

struct OnboardingScreen_Previews: PreviewProvider {
    static var previews: some View {
        LoginScreen()
    }
}
