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
    @State private var userName: String = ""
    @State private var userBio: String = ""
    @State private var profileImage: UIImage? = nil
    @State private var trainingPreferences: [String] = []
    @State private var posts: [Post] = []
    
    @State private var badges: [String] = []

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    //user info section
                    VStack(spacing: 8) {
                        if let profileImage = profileImage {
                            Image(uiImage: profileImage)
                                .resizable()
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 80, height: 80)
                                .foregroundColor(.gray)
                        }
                        
                        Text(userName)
                            .font(.custom(Theme.bodyFont, size: 23))
                            .bold()
                            .foregroundColor(.white)

                        Text(userBio)
                            .font(.custom(Theme.bodyFont, size: 16))
                            .foregroundColor(.gray)
                    }

                    //streak section
                    HStack {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                        Text("\(streakDays) Days")
                            .font(.custom(Theme.bodyFont, size: 20))
                            .bold()
                            .foregroundColor(.white)
                    }
                    .padding(.vertical, 5)

                    //training preferences section
                    if !trainingPreferences.isEmpty {
                        VStack(alignment: .leading) {
                            Text("Training Preferences")
                                .font(.custom(Theme.bodyFont, size: 17))
                                .foregroundColor(.white)
                                .padding(.horizontal)
                                .padding(.bottom, 5)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(trainingPreferences, id: \.self) { preference in
                                        Text(preference.capitalized)
                                            .font(.custom(Theme.bodyFont, size: 16))
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

                    //follower/following
                    HStack {
                        NavigationLink(destination: FollowingScreen(currentUser: user, category: "followers")) {
                            StatView(statNumber: "\(followersCount)", statLabel: "followers")
                        }
                        Spacer()
                        NavigationLink(destination: FollowingScreen(currentUser: user, category: "following")) {
                            StatView(statNumber: "\(followingCount)", statLabel: "following")
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 20)

                    //badges section
                    if !badges.isEmpty {
                        VStack(alignment: .leading) {
                            Text("Achievements")
                                .font(.custom(Theme.bodyFont, size: 17))
                                .foregroundColor(.white)
                                .padding(.horizontal)
                                .padding(.bottom, -5)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(badges, id: \.self) { badge in
                                        VStack(spacing: 5) {
                                            ZStack {
                                                Circle()
                                                    .fill(
                                                        LinearGradient(
                                                            gradient: Gradient(colors: [.yellow, .orange]),
                                                            startPoint: .topLeading,
                                                            endPoint: .bottomTrailing
                                                        )
                                                    )
                                                    .frame(width: 50, height: 50)
                                                
                                                Image(systemName: "medal.fill")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 30, height: 30)
                                                    .foregroundColor(.white)
                                            }

                                            Text(badge)
                                                .font(.custom(Theme.bodyFont, size: 14))
                                                .foregroundColor(.white)
                                        }
                                        .padding(10)
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(Theme.secondaryColor.opacity(0.2))
                                        )
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        .padding(.vertical, 10)

                    }


                    //post history section
                    VStack {
                        Text("Post History")
                            .font(.custom(Theme.bodyFont, size: 16))
                            .bold()
                            .foregroundColor(.white)

                        List($posts) { $post in
                            WorkoutPostCard(post: $post, currUserName: post.userName, currUserId: post.userId)
                                .listRowInsets(EdgeInsets())
                                .listRowBackground(Color.black)
                                .disabled(true)
                        }
                        .frame(height: 300)
                        .listStyle(.plain)
                    }
                }
                .padding()
            }
            .background(Color.black.ignoresSafeArea())
            .onAppear {
                fetchProfileData()
                fetchPosts(for: user.id)
            }
            .onDisappear {
                posts = []
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if settings {
                        NavigationLink(destination: SettingsView(user: user)) {
                            Image(systemName: "gearshape.fill")
                                .foregroundColor(.white)
                                .imageScale(.large)
                        }
                    }
                }
            }
            .toolbarBackground(.black, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }

    
    //follower/following stats
    struct StatView: View {
        let statNumber: String
        let statLabel: String
        
        var body: some View {
            VStack {
                Text(statNumber)
                    .font(.custom(Theme.headingFont, size: 15))
                    .foregroundColor(.white)

                Text(statLabel)
                    .font(.custom(Theme.bodyFont, size: 13))
                    .foregroundColor(.white)
            }
            .frame(width: 100, height: 45)
            .background(Theme.secondaryColor)
            .cornerRadius(10)
        }
    }

    private func fetchProfileData() {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(user.id)

        //fetch main user document
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
                self.badges = document.data()?["earnedBadges"] as? [String] ?? []
            } else {
                print("Error fetching profile data: \(error?.localizedDescription ?? "Unknown error")")
            }
        }

        userRef.collection("followers").getDocuments { snapshot, error in
            if let snapshot = snapshot {
                self.followersCount = snapshot.documents.count
            } else {
                print("Error fetching followers: \(error?.localizedDescription ?? "Unknown error")")
                self.followersCount = 0
            }
        }

        userRef.collection("following").getDocuments { snapshot, error in
            if let snapshot = snapshot {
                self.followingCount = snapshot.documents.count
            } else {
                print("Error fetching following: \(error?.localizedDescription ?? "Unknown error")")
                self.followingCount = 0
            }
        }
    }


    private func fetchPosts(for userId: String) {
        PostService.fetchPosts(userId: userId, includeFollowing: false) { fetchedPosts, error in
            if let error = error {
                print("Error fetching posts: \(error.localizedDescription)")
            } else {
                self.posts = fetchedPosts
            }
        }
    }
}
