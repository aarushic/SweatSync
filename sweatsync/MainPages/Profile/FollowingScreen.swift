//
//  FollowingScreen.swift
//  sweatsync
//
//  Created by Randy P on 11/10/24.
//
import FirebaseAuth
import SwiftUI
import Firebase

struct FollowingScreen: View {
    let currentUser: User
    let category: String
    @State private var listOfFollowers: [FollowUser] = []
    @State private var changes = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack {
                    Text("\(category)")
                        .font(.custom(Theme.bodyFont, size: 18))
                        .foregroundColor(.white)
                        .padding()
                        .cornerRadius(4)

                    List($listOfFollowers) { $follower in
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
                .padding(20)
            }
            .onAppear {
                getFollowing()
            }
        }
    }
    
    //get user's followers/followings and add into a list
    func getFollowing() {
        listOfFollowers = []
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(currentUser.id)
        userRef.collection("\(category.lowercased())").getDocuments { snapshot, error in
            if let snapshot = snapshot {
                for document in snapshot.documents {
                    let followerID = document.documentID
                    db.collection("users").document(document.documentID).getDocument { document, error in
                        if let error = error {
                            print("Error fetching \(category) info: \(error.localizedDescription)")
                        } else if let document = document, document.exists {
                            var userName = ""
                            var imageString = ""
                            
                            if let name = document.data()?["preferredName"] as? String {
                                userName = name
                                if let base64ImageString = document.data()?["profilePictureUrl"] as? String {
                                    imageString = base64ImageString
                                }
                            }
                            
                            var isFollowing = false
                            db.collection("users").document(currentUser.id).collection("following").document(followerID).getDocument { document, error in
                                if let document = document, document.exists {
                                    isFollowing = true
                                }
                                
                                let followerUser = FollowUser(
                                    id: followerID,
                                    user: User(id: followerID, preferredName: userName, profilePictureUrl: imageString),
                                    followStatus: isFollowing
                                )
                                
                                listOfFollowers.append(followerUser)
                            }
                        }
                    }
                }
            }
        }
    }

    func toggleFollowStatus(for follower: FollowUser) {
        if follower.followStatus {
            unfollowUser(follower.user)
        } else {
            followUser(follower.user)
        }
        
        if let index = listOfFollowers.firstIndex(where: { $0.id == follower.id }) {
            listOfFollowers[index].followStatus.toggle()
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

struct FollowUser: Identifiable {
    var id: String
    var user : User
    var followStatus: Bool
}
