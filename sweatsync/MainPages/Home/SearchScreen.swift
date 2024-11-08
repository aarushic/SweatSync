//
//  SearchScreen.swift
//  sweatsync
//
//  Created by Ashwin on 11/7/24.
//


import FirebaseAuth
import SwiftUI
import Firebase

struct SearchScreenView: View {
    @State private var searchEmail: String = ""
    @State private var foundUser: User? = nil
    @State private var searchStatus: String = ""
    @State private var isFollowing: Bool = false // To track if the current user is following the found user
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    HStack {
                        TextField("Enter email to search", text: $searchEmail)
                            .font(.custom("YourFontName", size: 19))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                        
                        Button(action: {
                            searchForUserByEmail()
                        }) {
                            Text("Search")
                                .foregroundColor(Theme.secondaryColor)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 20)
                                .background(Theme.primaryColor)
                                .cornerRadius(10)
                        }
                        .padding(.trailing)
                    }
                    .padding(.top, 40)
                    
                    if let user = foundUser {
                        NavigationLink(destination: ProfileScreen(user: user, settings: false).navigationBarBackButtonHidden(true)
                        ) {
                            UserProfileCardView(user: user, isFollowing: $isFollowing) {
                                toggleFollowStatus(for: user)
                            }
                        }
                        .buttonStyle(PlainButtonStyle()) // To prevent button styling in NavigationLink
                    } else {
                        Text(searchStatus)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                }
                .padding()
            }
        }
    }
    
    func searchForUserByEmail() {
        let db = Firestore.firestore()
        
        db.collection("users")
            .whereField("email", isEqualTo: searchEmail)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error searching for user: \(error.localizedDescription)")
                    self.searchStatus = "Error searching for user."
                } else if let snapshot = snapshot, !snapshot.isEmpty, let document = snapshot.documents.first {
                    let data = document.data()
                    let preferredName = data["preferredName"] as? String ?? "No Name"
                    //need to fix
                    let profilePictureUrl = data["profilePictureUrl"] as? String ?? ""
                    let uid = document.documentID
                    self.foundUser = User(id: uid, preferredName: preferredName, profilePictureUrl: profilePictureUrl)
                    self.checkIfFollowing(userId: uid)
                    self.searchStatus = ""
                } else {
                    self.searchStatus = "No user found with this email."
                    self.foundUser = nil
                }
            }
    }
    
    func checkIfFollowing(userId: String) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        
        db.collection("users").document(currentUserId).collection("following").document(userId).getDocument { document, error in
            if let document = document, document.exists {
                self.isFollowing = true
            } else {
                self.isFollowing = false
            }
        }
    }
    
    func toggleFollowStatus(for user: User) {
        if isFollowing {
            unfollowUser(user)
        } else {
            followUser(user)
        }
    }
    
    func followUser(_ user: User) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let currentUserRef = db.collection("users").document(currentUserId)
        let targetUserRef = db.collection("users").document(user.id)

        // Add to current user's following collection with a document reference
        db.collection("users").document(currentUserId).collection("following").document(user.id).setData([
            "userRef": targetUserRef
        ]) { error in
            if let error = error {
                print("Error following user: \(error.localizedDescription)")
            } else {
                print("You are now following \(user.preferredName)")
                self.isFollowing = true
            }
        }
        
        // Add to target user's followers collection with a document reference
        db.collection("users").document(user.id).collection("followers").document(currentUserId).setData([
            "userRef": currentUserRef
        ]) { error in
            if let error = error {
                print("Error adding follower: \(error.localizedDescription)")
            }
        }
    }

    func unfollowUser(_ user: User) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()

        // Remove from current user's following collection
        db.collection("users").document(currentUserId).collection("following").document(user.id).delete { error in
            if let error = error {
                print("Error unfollowing user: \(error.localizedDescription)")
            } else {
                print("You have unfollowed \(user.preferredName)")
                self.isFollowing = false
            }
        }

        // Remove from target user's followers collection
        db.collection("users").document(user.id).collection("followers").document(currentUserId).delete { error in
            if let error = error {
                print("Error removing follower: \(error.localizedDescription)")
            }
        }
    }


}

struct User: Identifiable {
    var id: String
    var preferredName: String
    var profilePictureUrl: String
}

struct UserProfileCardView: View {
    let user: User
    @Binding var isFollowing: Bool
    let action: () -> Void
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: user.profilePictureUrl)) { image in
                image.resizable()
                    .scaledToFill()
            } placeholder: {
                Color.gray
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())
            
            VStack(alignment: .leading) {
                Text(user.preferredName)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(isFollowing ? "Following" : "Not Following")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(action: action) {
                Text(isFollowing ? "Unfollow" : "Follow")
                    .foregroundColor(isFollowing ? .white : Theme.secondaryColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(isFollowing ? Color.red : Theme.primaryColor)
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
    }
}

struct SearchPreview: PreviewProvider {
    static var previews: some View {
        SearchScreenView()
    }
}
