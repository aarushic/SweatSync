//
//  WorkoutPost.swift
//  sweatsync
//
//  Created by aarushi chitagi on 10/14/24.
//

import Foundation
import SwiftUI

struct WorkoutPostCard: View {
    var body: some View {
        // Workout Post Card
        VStack(alignment: .leading, spacing: 15) {
            // Post Header (User Info)
            HStack {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(Color(red: 208/255, green: 247/255, blue: 147/255)) // Light green
                
                VStack(alignment: .leading) {
                    Text("Person Name")
                        .font(.headline)
                        .foregroundColor(.white)

                    HStack {
                        Text("Location, City")
                            .font(.subheadline)
                            .foregroundColor(.gray)

                        Spacer()

                        Text("2:55:00 PM")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }

                Spacer()

                // Menu Icon (3 dots)
                Button(action: {
                    // Menu action
                }) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal)
            .padding(.top, 10)

            // Post Title
            Text("Chest And Back Day")
                .font(.title2)
                .bold()
                .foregroundColor(.white)
                .padding(.horizontal)
            
            // Post Image
//            Image("workout_image") // Replace with actual image asset or URL image
//                .resizable()
//                .scaledToFit()
//                .frame(maxWidth: .infinity)
//                .cornerRadius(15)
//                .padding(.horizontal)

            // Like and Comment Buttons
            HStack(spacing: 30) {
                LikeButton()

                Button(action: {
                    // Comment action
                }) {
                    Image(systemName: "message")
                        .foregroundColor(.white)
                        .font(.title2)
                }
            }
            .padding()
            .background(Color(red: 32/255, green: 32/255, blue: 32/255)) // Dark background for buttons
            .cornerRadius(15)
            .padding(.horizontal)
            
        }
        .background(Color(red: 42/255, green: 42/255, blue: 42/255)) // Dark card background
        .cornerRadius(20)
        .padding(.horizontal)
        .padding(.vertical, 25)
    }
}

#Preview {
    WorkoutPostCard()
}
