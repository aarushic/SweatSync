//
//  CompleteProfileScreen.swift
//  sweatsync
//
//  Created by aarushi chitagi on 10/14/24.
//
import SwiftUI
import Firebase
import FirebaseAuth

struct ProfileScreen: View {
    let user: User
    let settings: Bool
    
    @State private var streakDays: Int = 0
    @State private var followersCount: Int = 0
    @State private var followingCount: Int = 0
    @State private var badges: [String] = []
    @State private var userName: String = ""
    @State private var userBio: String = ""
    @State private var profileImage: UIImage? = nil
    @State private var trainingPreferences: [String] = []
    
    var body: some View {
        NavigationView{
            VStack {
                // User Info Section
                VStack(spacing: 8) {
                    Text(userName)
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.white)
                    
                    if let profileImage = profileImage {
                        Image(uiImage: profileImage)
                            .resizable()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.gray)
                            .frame(width: 100, height: 100)
                    }
                    
                    Text(userBio)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                // Training Preferences Section
                if !trainingPreferences.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Training Preferences")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.top, 20)
                            .padding(.bottom, 5)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(trainingPreferences, id: \.self) { preference in
                                    Text(preference.capitalized)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(Theme.primaryColor)
                                        .foregroundColor(Theme.secondaryColor)
                                        .cornerRadius(20)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
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
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if settings {
                        NavigationLink(destination: SettingsView()) {
                            Image(systemName: "gearshape.fill")
                                .foregroundColor(.white)
                                .imageScale(.large)
                        }
                    }
                }
            }
        }
    }
    
    // Fetch profile data from Firebase
    private func fetchProfileData() {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(user.id)
        
        userRef.getDocument { document, error in
            if let document = document, document.exists {
                self.userName = document.data()?["preferredName"] as? String ?? "Name"
                self.userBio = document.data()?["bio"] as? String ?? "User Bio"
                self.streakDays = document.data()?["currentStreak"] as? Int ?? 0
                
                if let base64ImageString = document.data()?["profileImageBase64"] as? String,
                   let imageData = Data(base64Encoded: base64ImageString),
                   let image = UIImage(data: imageData) {
                    self.profileImage = image
                }
                
                self.trainingPreferences = document.data()?["trainingPreferences"] as? [String] ?? []
            } else {
                print("User document does not exist")
            }
        }
        
        // Fetch follower count
        userRef.collection("followers").getDocuments { snapshot, error in
            if let snapshot = snapshot {
                self.followersCount = snapshot.count
            }
        }
        
        // Fetch following count
        userRef.collection("following").getDocuments { snapshot, error in
            if let snapshot = snapshot {
                self.followingCount = snapshot.count
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

//#Preview {
//    ProfileScreen()
//}
