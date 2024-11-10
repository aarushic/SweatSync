//
//  TabBarView.swift
//  sweatsync
//
//  Created by aarushi chitagi on 10/14/24.
//

import Foundation
import SwiftUI
import FirebaseAuth
import Firebase

struct TabBarView: View {
    @State var user: User? = nil

    var body: some View {
        // Tab Bar
        TabView {
            HomeScreenView()
                .tabItem {
                    Image(systemName: "house.fill")
                }
            
            TemplatesView()
                .tabItem {
                    Image(systemName: "plus.circle.fill")
                }
        
            Text("Notifications Page - Final Release")
                .tabItem {
                    Image(systemName: "bell.fill")
                }
                .badge(2)
            
            if let user = user {
                ProfileScreen(user: user, settings: true)
                    .tabItem {
                        Image(systemName: "person.fill")
                    }
                
               
            } else {
                Text("Loading Profile...")
                    .tabItem {
                        Image(systemName: "person.fill")
                    }
            }
        }
        .toolbarBackground(Color(red: 42/255, green: 42/255, blue: 42/255), for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
        .onAppear {
            fetchCurrentUser()
        }
    }

    private func fetchCurrentUser() {
        guard let authUser = Auth.auth().currentUser else {
            print("User not logged in")
            return
        }

        let userId = authUser.uid
        let db = Firestore.firestore()

        db.collection("users").document(userId).getDocument { document, error in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
            } else if let document = document, document.exists {
                if let data = document.data() {
                    user = User(
                        id: userId,
                        preferredName: data["preferredName"] as? String ?? "Unknown",
                        profilePictureUrl: data["profilePictureUrl"] as? String ?? ""
                    )
                }
            }
        }
    }

}
struct TabBarViewPreview: PreviewProvider {
    static var previews: some View {
        TabBarView()
    }
}
