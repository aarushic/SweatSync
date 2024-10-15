//
//  CompleteProfileScreen.swift
//  sweatsync
//
//  Created by aarushi chitagi on 10/14/24.
//

import Foundation
import SwiftUI

struct CompleteProfileScreen: View {
    @State private var selectedGender: String = "Female"
    @State private var age: String = ""
    @State private var height: String = ""
    @State private var weight: String = ""

    var body: some View {
        VStack(spacing: 20) {
            // Top section with Back button and title
            HStack {
                Button(action: {
                    // Handle back action
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Color(red: 208/255, green: 247/255, blue: 147/255))
                }
                Spacer()
                Text("Back")
                    .foregroundColor(Color(red: 208/255, green: 247/255, blue: 147/255))
            }
            .padding()
            .background(Color.black)
            
            // Gender Selection
            VStack(alignment: .leading, spacing: 10) {
                Text("Gender")
                    .foregroundColor(.white)
                    .bold()
                
                HStack(spacing: 20) {
                    GenderButton(selectedGender: $selectedGender, gender: "Male", symbol: "person.fill")
                    GenderButton(selectedGender: $selectedGender, gender: "Female", symbol: "person.fill")
                    GenderButton(selectedGender: $selectedGender, gender: "Other", symbol: "questionmark.circle.fill")
                }
            }
            .padding(.horizontal, 30)
            
            // Input fields for Age, Height, and Weight
            VStack(spacing: 20) {
                TextField(
                        "Age",
                        text: $age
                    )
                    .onSubmit {
                        //do smth
                    }
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .textFieldStyle(.roundedBorder)
                TextField(
                        "Height",
                        text: $height
                    )
                    .onSubmit {
                        //do smth
                    }
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .textFieldStyle(.roundedBorder)
                TextField(
                        "Weight",
                        text: $weight
                    )
                    .onSubmit {
                        //do smth
                    }
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .textFieldStyle(.roundedBorder)
               
            }
            .padding()
            .background(Color(red: 208/255, green: 247/255, blue: 147/255))
            .cornerRadius(15)
            .padding(.horizontal, 30)
            
            // Complete Profile Button
            Button(action: {
                // Handle complete profile action
            }) {
                Text("Complete Profile")
                    .frame(width: 250, height: 50)
                    .background(Color(red: 208/255, green: 247/255, blue: 147/255))
                    .foregroundColor(.black)
                    .cornerRadius(25)
            }
            .padding(.top, 20)
            
            Spacer()
        }
        .background(Color.black.ignoresSafeArea())
    }
}

// Gender Button component
struct GenderButton: View {
    @Binding var selectedGender: String
    var gender: String
    var symbol: String

    var body: some View {
        Button(action: {
            selectedGender = gender
        }) {
            VStack {
                Image(systemName: symbol)
                    .foregroundColor(selectedGender == gender ? Color(red: 208/255, green: 247/255, blue: 147/255) : .gray)
                    .padding()
                    .background(selectedGender == gender ? Color.black : Color.gray)
                    .cornerRadius(10)
                Text(gender)
                    .foregroundColor(.white)
            }
        }
    }
}


struct CompleteProfile: PreviewProvider {
    static var previews: some View {
        CompleteProfileScreen()
    }
}
