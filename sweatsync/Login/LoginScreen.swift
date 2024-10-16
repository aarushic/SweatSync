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

    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                //top part
                HStack {
                    Button(action: {
                        //back
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                    }
                    Text("Log In")
                        .font(.headline)
                        .foregroundColor(Theme.primaryColor)
                        .frame(maxWidth: .infinity, alignment: .center)
                    Spacer()
                    Spacer()
                }
                .padding()
                .background(Color.black)
                
                //welcome
                VStack(spacing: 20) {
                    Text("Welcome")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.white)
                    
                    Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit.")
                        .font(.body)
                        .multilineTextAlignment(.center)
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
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(25)
                }
                .padding(.top, 20)
                
                //error
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.top, 10)
                }

                //google sign in
                Text("or sign in with")
                    .foregroundColor(.white)
                
                Button(action: {
                    //do later
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
                    NavigationLink(destination: SignUpScreen()) {
                        Text("Sign Up")
                            .foregroundColor(Theme.primaryColor)
                    }
                }
            }
            .background(Color.black.ignoresSafeArea())
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
            //success
            self.errorMessage = nil
            
            //navigate to next screen
        }
    }
}

struct OnboardingScreen_Previews: PreviewProvider {
    static var previews: some View {
        LoginScreen()
    }
}
