//
//  SignUpScreen.swift
//  sweatsync
//
//  Created by aarushi chitagi on 10/14/24.
//

import Foundation
import SwiftUI

struct SignUpScreen: View {
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""

    var body: some View {
        VStack(spacing: 30) {
            // Top section with back button and title
            HStack {
                Button(action: {
                   
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                }
                Text("Sign Up")
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
                Text("Get Started")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
            }
            .padding(.bottom, 30)
            
            // Login form fields
            VStack(spacing: 30) {
                TextField(
                        "First name",
                        text: $firstName
                    )
                    .onSubmit {
                        //do smth
                    }
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .textFieldStyle(.roundedBorder)
                TextField(
                        "Last name",
                        text: $lastName
                    )
                    .onSubmit {
                        //do smth
                    }
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .textFieldStyle(.roundedBorder)
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
                TextField(
                        "Confirm password",
                        text: $confirmPassword
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
                Text("Sign Up")
                    .frame(width: 200, height: 50)
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(25)
            }
            .padding(.top, 20)
            
            // Google Sign Up Button
            Text("or sign up with")
                .foregroundColor(.white)
            
            Button(action: {
                // Google Sign-in action
            }) {
                Image(systemName: "g.circle.fill") // You can replace with a Google icon image
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.white)
            }
            
            
            //sign up
            HStack {
                Text("Already have an account?")
                    .foregroundColor(.white)
                Button(action: {
                    //go to sign-up
                }) {
                    Text("Log in")
                        .foregroundColor(Theme.primaryColor)
                }
            }
        }
        .background(Color.black.ignoresSafeArea())
    }
}



struct SignUpScreen_Previews: PreviewProvider {
    static var previews: some View {
        SignUpScreen()
    }
}
