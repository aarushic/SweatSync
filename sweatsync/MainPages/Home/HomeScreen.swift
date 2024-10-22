//
//  HomeScreen.swift
//  sweatsync
//
//  Created by aarushi chitagi on 10/14/24.
//

import Foundation
import SwiftUI

struct HomeScreenView: View {
    var body: some View {
        VStack(spacing: 20) {
            // Header with user info and search icon
            HStack {
                // User Profile Picture and Info
                HStack {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(Color(red: 208/255, green: 247/255, blue: 147/255)) // Light green

                    VStack(alignment: .leading) {
                        Text("Hi, Name")
                            .font(.title3)
                            .bold()
                            .foregroundColor(.white)

                        Text("1 workout logged this week")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                // Search Icon
                Button(action: {
                    // Search action
                }) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(Color(red: 208/255, green: 247/255, blue: 147/255))
                        .font(.title)
                }
            }
            .padding(.horizontal)
            .padding(.top, 20)
            
            // Post feed
            // Replace individual cards with a ForLoop for each post
            List {
                WorkoutPostCard()
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.black)
                WorkoutPostCard()
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.black)
                WorkoutPostCard()
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.black)
            }
             .listStyle(.plain)
            //for loop of all posts that takes in parameters later
//            WorkoutPostCard()
            
            Spacer()

//            TabBarView()
        }
        .background(Color.black.ignoresSafeArea())
    }
}

struct HomeScreenPreview: PreviewProvider {
    static var previews: some View {
        HomeScreenView()
    }
}
