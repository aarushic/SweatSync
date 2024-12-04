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
        VStack() {
            //top part
            HStack {
                Text("Log In")
                    .font(.custom(Theme.headingFont, size: 22))
                    .foregroundColor(Theme.primaryColor)
                    .frame(alignment: .center)
            }
            .padding()
            .background(Color.black)
            
            //welcome message
            VStack(spacing: 20) {
                Text("Welcome")
                    .font(.custom(Theme.headingFont, size: 26))
                    .bold()
                    .foregroundColor(.white)
            }
            
            Text("Please login to continue.")
                .font(.custom(Theme.bodyFont, size: 19))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.vertical, 30)

            //login form fields
            VStack(spacing: 0) {
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Username or email")
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
                    .padding(.horizontal, 16)

                    VStack(alignment: .leading, spacing: 15) {
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
                    .padding(.horizontal, 16)
                }
                .padding(.vertical, 30)
                .frame(maxWidth: .infinity)
                .background(Theme.primaryColor)
                .cornerRadius(0)
            }
            .edgesIgnoringSafeArea(.horizontal)
            .padding(.vertical, 20)

            
            //log in button
            Button(action: {
                loginUser()
            }) {
                Text("Log In")
                    .frame(width: 200, height: 50)
                    .font(.custom(Theme.headingFont2, size: 19))
                    .background(Theme.secondaryColor)
                    .cornerRadius(25)
                    .foregroundColor(username.isEmpty || password.isEmpty ? Color.gray : Color.white)
            }
            .disabled(username.isEmpty || password.isEmpty)
            .padding(.bottom, 20)
            
            //error message
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.top, 10)
            }
            
            Spacer()
            
            //sign up option
            HStack {
                Text("Don't have an account?")
                    .font(.custom(Theme.bodyFont, size: 16))
                    .foregroundColor(.white)
                Button(action: {
                    isShowingSignUpScreen = true
                }) {
                    Text("Sign Up")
                        .foregroundColor(Theme.primaryColor)
                        .font(.custom(Theme.bodyFont, size: 16))
                }
            }
        }
        .padding(.bottom, 20)
        .background(Color.black.ignoresSafeArea())
        .onTapGesture {
            dismissKeyboard()
        }
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
            session.signIn()
            isShowingHomeScreen = true
        }
    }
}

func dismissKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
}

struct OnboardingScreen_Previews: PreviewProvider {
    static var previews: some View {
        LoginScreen()
    }
}
