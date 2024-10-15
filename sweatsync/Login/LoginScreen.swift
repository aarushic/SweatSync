//
//  LoginScreen.swift
//  sweatsync
//
//  Created by aarushi chitagi on 10/14/24.
//

import Foundation
import SwiftUI

struct LoginScreen: View {
    @State private var username: String = ""
    @State private var password: String = ""

    var body: some View {
        VStack(spacing: 30) {
            // Top section with back button and title
            HStack {
                Button(action: {
                   
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
            
            // Welcome Text
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
            
            // Login form fields
            VStack(spacing: 30) {
                TextField(
                        "Username (email address)",
                        text: $username
                    )
                    .onSubmit {
                        //do smth
                    }
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .textFieldStyle(.roundedBorder)
                TextField(
                        "Password ",
                        text: $password
                    )
                    .onSubmit {
                        //do smth
                    }
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .textFieldStyle(.roundedBorder)
                    
            }
            .padding()
            .background(Theme.primaryColor)
            
            // Log In Button
            Button(action: {
                // Log in action
            }) {
                Text("Log In")
                    .frame(width: 200, height: 50)
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(25)
            }
            .padding(.top, 20)
            
            // Google Sign In Button
            Text("or sign in with")
                .foregroundColor(.white)
            
            Button(action: {
                // Google Sign-in action
            }) {
                Image(systemName: "g.circle.fill") // You can replace with a Google icon image
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            //sign up
            HStack {
                Text("Don't have an account?")
                    .foregroundColor(.white)
                Button(action: {
                    //go to sign-up
                }) {
                    Text("Sign Up")
                        .foregroundColor(Color(red: 208/255, green: 247/255, blue: 147/255))
                }
            }
        }
        .background(Color.black.ignoresSafeArea())
    }
}



struct OnboardingScreen_Previews: PreviewProvider {
    static var previews: some View {
        LoginScreen()
    }
}
