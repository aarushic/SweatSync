//
//  CompleteProfileScreen.swift
//  sweatsync
//
//  Created by aarushi chitagi on 10/14/24.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ProfileScreen: View {
    @State private var streakDays: Int = 0
    @State private var followersCount: Int = 0
    @State private var followingCount: Int = 0
    @State private var badges: [String] = []
    @State private var userName: String = "Name"
    @State private var userBio: String = "User Bio. Hi My Name Is Blah Blah"

    var body: some View {
        NavigationView {
            VStack {
                // User Info Section
                VStack(spacing: 8) {
                    Text(userName)
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.white)
                        .padding(.top, 20)
                    
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.gray)
                    
                    Text(userBio)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                // Streak Section
                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                    Text("\(streakDays) Days")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                }
                .padding(.top, 10)
                
                // Follower and Following Section
                HStack {
                    StatView(statNumber: "\(followersCount)", statLabel: "followers")
                    Spacer()
                    StatView(statNumber: "\(followingCount)", statLabel: "following")
                }
                .padding(.horizontal, 40)
                .padding(.top, 20)

                // Badges Section
                HStack(spacing: 40) {
                    ForEach(badges, id: \.self) { badge in
                        AchievementView(title: badge, iconName: "star.circle.fill")
                    }
                }
                .padding(.top, 20)
                
                Spacer()
            }
            .padding()
            .background(Color.black.ignoresSafeArea())
            .onAppear(perform: fetchProfileData)
            .navigationBarTitleDisplayMode(.inline) // Show toolbar without title
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.white)
                            .imageScale(.large)
                    }
                }
            }
        }
    }
    
    // Fetch profile data from Firebase
    private func fetchProfileData() {
        guard let user = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(user.uid)
        
        // Fetch user's profile details (streak, bio, name, followers/following)
        userRef.getDocument { document, error in
            if let document = document, document.exists {
                self.userName = document.data()?["name"] as? String ?? "Name"
                self.userBio = document.data()?["bio"] as? String ?? "User Bio. Hi My Name Is Blah Blah"
                self.streakDays = document.data()?["currentStreak"] as? Int ?? 0
                self.followersCount = document.data()?["followersCount"] as? Int ?? 0
                self.followingCount = document.data()?["followingCount"] as? Int ?? 0
            } else {
                print("User document does not exist")
            }
        }
        
        // Fetch badges
        userRef.collection("badges").getDocuments { snapshot, error in
            if let snapshot = snapshot {
                self.badges = snapshot.documents.compactMap { $0.data()["name"] as? String }
            }
        }
    }
}

// Subview for Followers and Following stats
struct StatView: View {
    let statNumber: String
    let statLabel: String
    
    var body: some View {
        VStack {
            Text(statNumber)
                .font(.title)
                .bold()
                .foregroundColor(.white)
            Text(statLabel)
                .font(.caption)
                .foregroundColor(.white)
        }
        .frame(width: 100, height: 50)
        .background(Color.gray.opacity(0.3))
        .cornerRadius(10)
    }
}

// Subview for Achievements (Badges)
struct AchievementView: View {
    let title: String
    let iconName: String
    
    var body: some View {
        VStack {
            Image(systemName: iconName)
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundColor(.yellow)
            Text(title)
                .font(.headline)
                .bold()
                .foregroundColor(.white)
        }
    }
}

#Preview {
    ProfileScreen()
}
