//
//  HomeScreen.swift
//  sweatsync
//
//  Created by aarushi chitagi on 10/14/24.
//
import FirebaseAuth
import SwiftUI
import Firebase

struct HomeScreenView: View {
    @State private var mainUserName: String = ""
    @State private var posts: [Post] = []
    @State private var profileImage: UIImage? = nil
    
    var workoutsThisWeek: Int {
        let calendar = Calendar.current
        let today = Date()

        // Find the most recent Sunday
        let components = calendar.dateComponents([.weekday], from: today)
        let daysSinceSunday = (components.weekday! - 1 + 7) % 7
        let lastSunday = calendar.date(byAdding: .day, value: -daysSinceSunday, to: today)!

        // Set `lastSunday` to midnight
        let startOfLastSunday = calendar.startOfDay(for: lastSunday)


        return posts.filter { post in
            guard let currentUser = Auth.auth().currentUser?.uid else { return false }
            // Debugging output for each post
            print("Post Timestamp: \(post.timestamp), UserId: \(post.userId)")
            return post.userId == currentUser &&
                post.timestamp >= startOfLastSunday &&
                post.timestamp <= today
        }.count
    }


    var body: some View {
        NavigationView {
            
            VStack(spacing: 20) {
                // Home Screen Header
                HStack {
                    if let profileImage = profileImage {
                        Image(uiImage: profileImage)
                            .resizable()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(Theme.primaryColor)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Hi, \(mainUserName)")
                            .font(.custom(Theme.headingFont, size: 20))
                            .bold()
                            .foregroundColor(.white)
                        
                        Text("\(workoutsThisWeek) workouts logged this week")
                            .font(.custom(Theme.bodyFont, size: 16))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    NavigationLink(destination: SearchScreenView()) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Theme.primaryColor)
                            .font(.custom(Theme.bodyFont2, size: 22))
                    }
                }
                .padding(.horizontal)
                
                // Post Feed Section
                List($posts) { $post in
                    WorkoutPostCard(post: $post, currUserName: mainUserName, currUserId: post.userId)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.black)
                }
                .listStyle(.plain)
            }
            .padding()
            .background(Color.black.ignoresSafeArea())
            .onAppear {
                fetchProfileData()
                fetchPosts()
            }
        }
    }

    private func fetchProfileData() {
        guard let currentUser = Auth.auth().currentUser else {
            print("User not logged in")
            return
        }

        let db = Firestore.firestore()
        let userRef = db.collection("users").document(currentUser.uid)

        userRef.getDocument { document, error in
            if let document = document, document.exists {
                self.mainUserName = document.data()?["preferredName"] as? String ?? "Name"

                if let base64ImageString = document.data()?["profileImageBase64"] as? String,
                   let imageData = Data(base64Encoded: base64ImageString),
                   let image = UIImage(data: imageData) {
                    self.profileImage = image
                }
            } else {
                print("Error fetching profile data: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

    private func fetchPosts() {
        guard let currentUser = Auth.auth().currentUser else {
            print("User not logged in")
            return
        }

        PostService.fetchPosts(userId: currentUser.uid, includeFollowing: true) { fetchedPosts, error in
            if let error = error {
                print("Error fetching posts: \(error.localizedDescription)")
            } else {
                self.posts = fetchedPosts
            }
        }
    }
}

