//
//  RecommendationScreen.swift
//  sweatsync
//
//  Created by Randy P on 12/5/24.
//

import SwiftUI
import FirebaseAuth
import Firebase

struct RecommendationScreen: View {
    
    @State private var listOfUsers: [FollowUser] = []
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                VStack {
                    Text("Suggested Users")
                        .font(.custom(Theme.bodyFont, size: 18))
                        .foregroundColor(.white)
                        .padding()
                        .cornerRadius(4)
                    
                    List($listOfUsers) { $follower in
                        NavigationLink(
                            destination: ProfileScreen(user: follower.user, settings: false).navigationBarBackButtonHidden(true)
                        ) {
                            UserProfileCardView(user: follower.user, isFollowing: $follower.followStatus) {
                                toggleFollowStatus(for: follower)
                            }
                            .background(Color.black.ignoresSafeArea())
                        }
                        .buttonStyle(PlainButtonStyle())
                        .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                        .listRowBackground(Color.black)
                    }
                    .listStyle(.plain)
                    .background(Color.black.ignoresSafeArea())
                    
                    Spacer()
                }
            }.onAppear {
                //algorithm to recommend users based on similar preferences
                getRecommendations()
            }
        }
    }
    
    //recommend users to follow based on the current user's preferences
    func getRecommendations() {
        guard let currentUser = Auth.auth().currentUser else {
            print("User not logged in")
            return
        }
        let db = Firestore.firestore()
        let curUserRef = db.collection("users").document(currentUser.uid)
        listOfUsers = []
        //get current user preferences
        curUserRef.getDocument { document, error in
            if let document, document.exists {
                let userPreferences = document.data()?["trainingPreferences"] as? [String] ?? []
                if !userPreferences.isEmpty {
                    //get collection of users that have similar training preferences in common
                    let userRef = db.collection("users").whereField("trainingPreferences", arrayContainsAny: userPreferences)
                    userRef.getDocuments { snapshot, error in
                        if let snapshot = snapshot {
                            for document in snapshot.documents {
                                let recommendedID = document.documentID
                                if(recommendedID != currentUser.uid){
                                    //create a user object for recommended user
                                    db.collection("users").document(document.documentID).getDocument { document, error in
                                        if let error = error {
                                            print("Error fetching user info: \(error.localizedDescription)")
                                        } else if let document = document, document.exists {
                                            var userName = ""
                                            var imageString = ""
                                            
                                            if let name = document.data()?["preferredName"] as? String {
                                                userName = name
                                                if let base64ImageString = document.data()?["profilePictureUrl"] as? String {
                                                    imageString = base64ImageString
                                                }
                                            }
                                        
                                            db.collection("users").document(currentUser.uid).collection("following").document(recommendedID).getDocument { document, error in
                                                if let document = document, document.exists {
                                                    return
                                                }
                                                else {
                                                    let followerUser = FollowUser(
                                                        id: recommendedID,
                                                        user: User(id: recommendedID, preferredName: userName, profilePictureUrl: imageString),
                                                        followStatus: false
                                                    )
                                                    print(followerUser.id)
                                                    listOfUsers.append(followerUser)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            else {
                print("Error fetching profile data: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    func toggleFollowStatus(for follower: FollowUser) {
        if follower.followStatus {
            unfollowUser(follower.user)
        } else {
            followUser(follower.user)
        }
        
        if let index = listOfUsers.firstIndex(where: { $0.id == follower.id }) {
            listOfUsers[index].followStatus.toggle()
        }
    }
    
    func followUser(_ user: User) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let currentUserRef = db.collection("users").document(currentUserId)
        let targetUserRef = db.collection("users").document(user.id)

        db.collection("users").document(currentUserId).collection("following").document(user.id).setData([
            "userRef": targetUserRef
        ]) { error in
            if let error = error {
                print("Error following user: \(error.localizedDescription)")
            } else {
                print("You are now following \(user.preferredName)")
            }
        }
        
        db.collection("users").document(user.id).collection("followers").document(currentUserId).setData([
            "userRef": currentUserRef
        ]) { error in
            if let error = error {
                print("Error adding follower: \(error.localizedDescription)")
            } else {
                print("\(user.preferredName) has been notified of the follow.")
                
                sendFollowNotification(to: user.id, from: currentUserId)
            }
        }
    }

    func unfollowUser(_ user: User) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()

        db.collection("users").document(currentUserId).collection("following").document(user.id).delete { error in
            if let error = error {
                print("Error unfollowing user: \(error.localizedDescription)")
            } else {
                print("You have unfollowed \(user.preferredName)")
            }
        }

        db.collection("users").document(user.id).collection("followers").document(currentUserId).delete { error in
            if let error = error {
                print("Error removing follower: \(error.localizedDescription)")
            }
        }
    }
}
