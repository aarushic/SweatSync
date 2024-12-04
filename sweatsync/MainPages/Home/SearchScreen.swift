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
   @State private var isFollowing: Bool = false
   
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    HStack(spacing: 10) {
                        ZStack(alignment: .leading) {
                           if searchEmail.isEmpty {
                               Text("Enter email to search")
                                   .foregroundColor(.white.opacity(0.5))
                                   .padding(.leading, 15)
                                   .font(.custom(Theme.bodyFont, size: 18))
                           }
                           
                           TextField("", text: $searchEmail)
                               .font(.custom(Theme.bodyFont, size: 18))
                               .foregroundColor(.white)
                               .padding()
                               .background(Color.gray.opacity(0.2))
                               .cornerRadius(10)
                               .frame(height: 50)
                               .textInputAutocapitalization(.never)
                               .disableAutocorrection(true)
                               .onSubmit {
                                   dismissKeyboard()
                               }
                       }
                       
                        Button(action: {
                            searchForUserByEmail()
                        }) {
                            Text("Search")
                                .font(.custom(Theme.bodyFont, size: 18))
                                .foregroundColor(Theme.secondaryColor)
                                .frame(height: 50)
                                .padding(.horizontal, 20)
                                .background(Theme.primaryColor)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.top, 40)
                    
                    if let user = foundUser {
                        NavigationLink(destination: ProfileScreen(user: user, settings: false).navigationBarBackButtonHidden(true)
                        ) {
                            UserProfileCardView(user: user, isFollowing: $isFollowing) {
                                toggleFollowStatus(for: user)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    } else {
                        Text(searchStatus)
                            .font(.custom(Theme.bodyFont, size: 16))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .onTapGesture {
                dismissKeyboard()
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
        
        //add to target user's followers collection with a document reference
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

        //remove from current user's following collection
        db.collection("users").document(currentUserId).collection("following").document(user.id).delete { error in
            if let error = error {
                print("Error unfollowing user: \(error.localizedDescription)")
            } else {
                print("You have unfollowed \(user.preferredName)")
                self.isFollowing = false
            }
        }

        //remove from target user's followers collection
        db.collection("users").document(user.id).collection("followers").document(currentUserId).delete { error in
            if let error = error {
                print("Error removing follower: \(error.localizedDescription)")
            }
        }
    }
}

struct SearchPreview: PreviewProvider {
    static var previews: some View {
        SearchScreenView()
    }
}
