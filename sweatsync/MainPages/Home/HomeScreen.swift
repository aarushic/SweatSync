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
    @State private var userName: String = ""
    @State private var mainUserName: String = ""
    @State private var timestamp: String = ""
    @State private var posts: [Post] = []
    @State private var isLoading = true
    @State private var profileImage: UIImage? = nil
    
    var body: some View {
        NavigationView{
            VStack(spacing: 20) {
                // Profile Header
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
                            .font(.title3)
                            .bold()
                            .foregroundColor(.white)
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                                    self.getUser()
                                    self.fetchPosts()
                                }
                            }
                        
                        Text("1 workout logged this week")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    NavigationLink(destination: SearchScreenView()) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Theme.primaryColor)
                            .font(.title)
                    }
 
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                // Post Feed
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                } else {
                    List($posts) { $post in
                        WorkoutPostCard(post: $post, currUserName: mainUserName)
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.black)
                    }.listStyle(.plain)
                }
                
                Spacer()
            }
            .background(Color.black.ignoresSafeArea())
        }
    }

    func getUser() {
        guard let user = Auth.auth().currentUser else {
            print("User not logged in")
            return
        }

        let userId = user.uid
        let db = Firestore.firestore()

        db.collection("users").document(userId).getDocument { document, error in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
            } else if let document = document, document.exists {
                if let fetchedName = document.data()?["preferredName"] as? String {
                    self.mainUserName = fetchedName
                } else {
                    print("Error fetching preferred name")
                }
                
                if let base64ImageString = document.data()?["profileImageBase64"] as? String,
                   let imageData = Data(base64Encoded: base64ImageString),
                   let image = UIImage(data: imageData) {
                    self.profileImage = image
                }
            }
        }
    }
    
    func fetchPosts() {
        guard let user = Auth.auth().currentUser else {
            print("User not logged in")
            return
        }

        let db = Firestore.firestore()
        let userId = user.uid
        
        db.collection("users").document(userId).getDocument { document, error in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
            } else if let document = document, document.exists {
                if let fetchedName = document.data()?["preferredName"] as? String {
                    let userName = fetchedName
                    self.mainUserName = fetchedName
                   

                    if let base64ImageString = document.data()?["profileImageBase64"] as? String,
                       let imageData = Data(base64Encoded: base64ImageString),
                       let image = UIImage(data: imageData) {
                        self.profileImage = image
                    }

                    // Print after fetching the userName
                    print(userName)
                    
                    // Initialize an empty array to collect all posts
                    var allPosts: [Post] = []

                    // Fetch current user's posts
                    db.collection("users").document(userId).collection("posts").getDocuments { snapshot, error in
                        if let error = error {
                            print("Error fetching user's posts: \(error.localizedDescription)")
                            self.isLoading = false
                            return
                        }

                        if let documents = snapshot?.documents {
                            let userPosts = documents.compactMap { document in
                                var exercises: [Exercise] = []
                                if let exerciseArray = document.data()["exercises"] as? [[String: Any]] {
                                    exercises = exerciseArray.compactMap { data in
                                        let exercise = Exercise()
                                        exercise.exerciseType = data["exerciseType"] as? String ?? ""
                                        exercise.exerciseName = data["exerciseName"] as? String ?? ""
                                        exercise.warmUpSets = (data["warmUpSets"] as? [[String: String]])?.map { ($0["weight"]!, $0["reps"]!) } ?? []
                                        exercise.workingSets = (data["workingSets"] as? [[String: String]])?.map { ($0["weight"]!, $0["reps"]!) } ?? []
                                        exercise.notes = data["notes"] as? String ?? ""
                                        return exercise
                                    }
                                }

                                let timestamp = (document.data()["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                                print(userName)
                                
                                return Post(id: document.documentID, userId: userId, templateName: document.data()["templateName"] as? String ?? "", exercises: exercises, userName: userName, timestamp: timestamp)
                            }
                            allPosts.append(contentsOf: userPosts)
                        }

                        // Fetch followed users' posts
                        db.collection("users").document(userId).collection("following").getDocuments { followingSnapshot, error in
                            if let error = error {
                                print("Error fetching following list: \(error.localizedDescription)")
                                self.isLoading = false
                                return
                            }

                            let followingIds = followingSnapshot?.documents.compactMap { $0.documentID } ?? []
                            
                            let group = DispatchGroup() 

                            for followedUserId in followingIds {
                                group.enter()
                                db.collection("users").document(followedUserId).getDocument { userDocument, error in
                                    if let userDocument = userDocument, userDocument.exists, let followedUserName = userDocument.data()?["preferredName"] as? String {
                                        
                                        db.collection("users").document(followedUserId).collection("posts").getDocuments { postSnapshot, error in
                                            if let postDocuments = postSnapshot?.documents {
                                                let followedUserPosts = postDocuments.compactMap { document in
                                                    var exercises: [Exercise] = []
                                                    if let exerciseArray = document.data()["exercises"] as? [[String: Any]] {
                                                        exercises = exerciseArray.compactMap { data in
                                                            let exercise = Exercise()
                                                            exercise.exerciseType = data["exerciseType"] as? String ?? ""
                                                            exercise.exerciseName = data["exerciseName"] as? String ?? ""
                                                            exercise.warmUpSets = (data["warmUpSets"] as? [[String: String]])?.map { ($0["weight"]!, $0["reps"]!) } ?? []
                                                            exercise.workingSets = (data["workingSets"] as? [[String: String]])?.map { ($0["weight"]!, $0["reps"]!) } ?? []
                                                            exercise.notes = data["notes"] as? String ?? ""
                                                            return exercise
                                                        }
                                                    }
                                                    
                                                    let timestamp = (document.data()["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                                                    
                                                    return Post(id: document.documentID, userId: followedUserId, templateName: document.data()["templateName"] as? String ?? "", exercises: exercises, userName: followedUserName, timestamp: timestamp)
                                                }
                                                allPosts.append(contentsOf: followedUserPosts)
                                            }
                                            group.leave()
                                        }
                                    } else {
                                        group.leave()
                                    }
                                }
                            }
                            
                            group.notify(queue: .main) {
                                //sort posts by timestamp in descending order (newest first)
                                self.posts = allPosts.sorted(by: { $0.timestamp > $1.timestamp })
                                self.isLoading = false
                            }
                        }
                    }
                } else {
                    print("Error fetching preferred name")
                }
            }
        }
    }
}




struct HomeScreenPreview: PreviewProvider {
    static var previews: some View {
        HomeScreenView()
    }
}
