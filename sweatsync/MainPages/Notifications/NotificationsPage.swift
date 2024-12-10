//
//  Notifications.swift
//  sweatsync
//
//  Created by Ashwin on 11/29/24.
//

import SwiftUI
import Firebase

struct NotificationsPage: View {
    @State private var notifications: [Notification] = []
    
    let user: User

    var body: some View {
        VStack {
            Text("Notifications")
                .font(.custom(Theme.bodyFont, size: 24))
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.top, 20)
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(notifications) { notification in
                        NotifRow(notification: notification)
                    }
                }
                .padding()
            }
            .onAppear {
                fetchNotifications(for: user.id) { fetchedNotifications in
                    notifications = fetchedNotifications
                    markAllNotificationsAsRead(for: user.id)
                }
            }
        }
        .background(Color.black.ignoresSafeArea())
    }
}


func markAllNotificationsAsRead(for userId: String) {
    let db = Firestore.firestore()
    let userNotificationsRef = db.collection("users").document(userId).collection("notifications")
    
    userNotificationsRef.whereField("read", isEqualTo: false).getDocuments { snapshot, error in
        guard let documents = snapshot?.documents, error == nil else {
            print("Error fetching unread notifications: \(error?.localizedDescription ?? "Unknown error")")
            return
        }

        let batch = db.batch()
        for document in documents {
            batch.updateData(["read": true], forDocument: document.reference)
        }

        batch.commit { error in
            if let error = error {
                print("Error marking notifications as read: \(error.localizedDescription)")
            } else {
                print("All notifications marked as read successfully.")
            }
        }
    }
}

func fetchNotifications(for userId: String, completion: @escaping ([Notification]) -> Void) {
    let db = Firestore.firestore()
    db.collection("users").document(userId).collection("notifications")
        .order(by: "timestamp", descending: true)
        .getDocuments { snapshot, error in
            guard let documents = snapshot?.documents, error == nil else {
                print("Error fetching notifications: \(error?.localizedDescription ?? "Unknown error")")
                // Return an empty array if there's an error
                completion([])
                return
            }

            let notifications: [Notification] = documents.compactMap { doc in
                let data = doc.data()
                return Notification(
                    id: data["id"] as? String ?? "",
                    type: data["type"] as? String ?? "",
                    fromUserId: data["fromUserId"] as? String ?? "",
                    fromUserName: data["fromUserName"] as? String ?? "Someone",
                    fromUserProfilePictureUrl: data["fromUserProfilePictureUrl"] as? String ?? "",
                    postId: data["postId"] as? String ?? "",
                    postTitle: data["postTitle"] as? String ?? "",
                    content: data["content"] as? String,
                    timestamp: (data["timestamp"] as? Timestamp)?.dateValue() ?? Date(),
                    read: data["read"] as? Bool ?? false
                )
            }
            completion(notifications)
        }
}
