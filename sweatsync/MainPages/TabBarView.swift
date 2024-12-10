//
//  TabBarView.swift
//  sweatsync
//
//  Created by Aarushi Chitagi on 10/14/24.
//

import Foundation
import SwiftUI
import FirebaseAuth
import Firebase

struct TabBarView: View {
    @State var user: User? = nil
    @State private var notifications: [Notification] = []
    @State private var selectedTab: Int = 0
    
    var body: some View {
        //tab bar
        TabView(selection: $selectedTab) {
            HomeScreenView()
                .tabItem {
                    Image(systemName: "house.fill")
                }
                .tag(0)
            
            TemplatesView()
                .tabItem {
                    Image(systemName: "plus.circle.fill")
                }
                .tag(1)
            
            //update notification badge
            if let user = user {
                var unreadCount = notifications.filter { !$0.read }.count
                
                if unreadCount > 0 {
                    NotificationsPage(user: user)
                        .tabItem {
                            Image(systemName: "bell.fill")
                        }
                        .badge(unreadCount)
                        .tag(2)
                        .onAppear {
                            markAllNotificationsAsRead(for: user.id)
                            DispatchQueue.main.async {
                                for index in notifications.indices {
                                    notifications[index].read = true
                                }
                            }
                            unreadCount = notifications.filter { !$0.read }.count
                            print(unreadCount)
                        }
                } else {
                    NotificationsPage(user: user)
                        .tabItem {
                            Image(systemName: "bell.fill")
                        }
                        .tag(2)
                        .onAppear {
                            markAllNotificationsAsRead(for: user.id)
                            DispatchQueue.main.async {
                                for index in notifications.indices {
                                    notifications[index].read = true
                                }
                            }
                            unreadCount = notifications.filter { !$0.read }.count
                            print(unreadCount)
                        }
                }
            }
            
            if let user = user {
                ProfileScreen(user: user, settings: true)
                    .tabItem {
                        Image(systemName: "person.fill")
                    }
                    .tag(3)
            }
        }
        .toolbarBackground(Color(red: 42/255, green: 42/255, blue: 42/255).opacity(1.0), for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
        .onAppear {
            setupTabBarAppearance()
            fetchCurrentUser { fetchedUser in
                if let fetchedUser = fetchedUser {
                    fetchNotifications(for: fetchedUser.id) { fetchedNotifications in
                        notifications = fetchedNotifications
                    }
                }
            }
        }
    }
    
    private func fetchCurrentUser(completion: @escaping (User?) -> Void) {
        guard let authUser = Auth.auth().currentUser else {
            print("User not logged in")
            completion(nil)
            return
        }

        let userId = authUser.uid
        let db = Firestore.firestore()

        db.collection("users").document(userId).getDocument { document, error in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
                completion(nil)
            } else if let document = document, document.exists, let data = document.data() {
                let fetchedUser = User(
                    id: userId,
                    preferredName: data["preferredName"] as? String ?? "Unknown",
                    profilePictureUrl: data["profilePictureUrl"] as? String ?? ""
                )
                user = fetchedUser
                completion(fetchedUser)
            } else {
                completion(nil)
            }
        }
    }
    
    private func setupTabBarAppearance() {
        let standardAppearance = UITabBarAppearance()
        standardAppearance.configureWithDefaultBackground()
        standardAppearance.backgroundColor = UIColor(Color.black)
        UITabBar.appearance().standardAppearance = standardAppearance
        
        let scrollEdgeAppearance = UITabBarAppearance()
        scrollEdgeAppearance.configureWithTransparentBackground()
        UITabBar.appearance().scrollEdgeAppearance = scrollEdgeAppearance
    }
}

struct TabBarViewPreview: PreviewProvider {
    static var previews: some View {
        TabBarView()
    }
}
