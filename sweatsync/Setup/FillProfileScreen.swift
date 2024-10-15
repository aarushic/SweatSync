//
//  FillProfileScreen.swift
//  sweatsync
//
//  Created by aarushi chitagi on 10/14/24.
//

import Foundation
import SwiftUI

struct FillProfileScreen: View {
    @State private var preferredName: String = ""
    @State private var bio: String = ""

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
            
            // Fill Your Profile Title
            Text("Fill Your Profile")
                .font(.title)
                .bold()
                .foregroundColor(.white)
                .padding(.top, 20)
            
            // Profile Picture Placeholder
            Circle()
                .fill(Color(red: 208/255, green: 247/255, blue: 147/255))
                .frame(width: 100, height: 100)
                .overlay(
                    Image(systemName: "person.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.gray)
                )
                .padding(.bottom, 20)
            
            // Input fields for Preferred Name and Bio
            VStack(spacing: 20) {
                TextField(
                        "Bio",
                        text: $bio
                    )
                    .onSubmit {
                        //do smth
                    }
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .textFieldStyle(.roundedBorder)
                TextField(
                        "Preferred name",
                        text: $preferredName
                    )
                    .onSubmit {
                        //do smth
                    }
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .textFieldStyle(.roundedBorder)            }
            .padding()
            .background(Color(red: 208/255, green: 247/255, blue: 147/255))
            .cornerRadius(15)
            .padding(.horizontal, 30)
            
            // Continue Button
            Button(action: {
                // Handle continue action
            }) {
                Text("Continue")
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


struct FillProfile: PreviewProvider {
    static var previews: some View {
        FillProfileScreen()
    }
}
