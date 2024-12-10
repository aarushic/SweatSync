import Foundation
import Firebase
import UserNotifications

//helper function to send a notification
func sendNotification(to userId: String, notificationData: [String: Any]) {
    let db = Firestore.firestore()
    
    db.collection("users").document(userId).collection("notifications").addDocument(data: notificationData) { error in
        if let error = error {
            print("Error sending notification: \(error.localizedDescription)")
        } else {
            print("Notification sent to \(userId).")
        }
    }
}

//helper function to fetch user data
func fetchUserData(userId: String, completion: @escaping (String, String) -> Void) {
    let db = Firestore.firestore()
    db.collection("users").document(userId).getDocument { document, error in
        if let error = error {
            print("Error fetching user data: \(error.localizedDescription)")
            // default value for code stability
            completion("Someone", "")
        } else if let document = document, let data = document.data() {
            let userName = data["preferredName"] as? String ?? "Someone"
            let profilePictureUrl = data["profilePictureUrl"] as? String ?? ""
            completion(userName, profilePictureUrl)
        } else {
            completion("Someone", "")
        }
    }
}

//function to send a follow notification
func sendFollowNotification(to userId: String, from currentUserId: String) {
    fetchUserData(userId: currentUserId) { userName, profilePictureUrl in
        let notificationData: [String: Any] = [
            "id": UUID().uuidString,
            "type": "follow",
            "fromUserId": currentUserId,
            "fromUserName": userName,
            "fromUserProfilePictureUrl": profilePictureUrl,
            "timestamp": Date(),
            "read": false
        ]
        sendNotification(to: userId, notificationData: notificationData)
        scheduleNotificationForUser(userId: userId, title: "New Follower", body: "\(userName) just followed you", triggerTime: 1)
    }
}

//helper function to send a comment notification
func sendCommentNotification(to postOwnerId: String, by commenterId: String, content: String, postId: String, postTitle: String) {
    fetchUserData(userId: commenterId) { commenterName, commenterProfilePictureUrl in
        let notificationData: [String: Any] = [
            "id": UUID().uuidString,
            "type": "comment",
            "fromUserId": commenterId,
            "fromUserName": commenterName,
            "fromUserProfilePictureUrl": commenterProfilePictureUrl,
            "content": content,
            "postId": postId,
            "postTitle": postTitle,
            "timestamp": Date(),
            "read": false
        ]
        sendNotification(to: postOwnerId, notificationData: notificationData)
        scheduleNotificationForUser(userId: postOwnerId, title: "Comment on your post", body: "\(commenterName) commented: \"\(content)\" on your post \"\(postTitle)\"", triggerTime: 1)
    }
}

//helper function to send a like notification
func sendLikeNotification(to postOwnerId: String, by likerId: String, postId: String, postTitle: String) {
    fetchUserData(userId: likerId) { likerName, likerProfilePictureUrl in
        let notificationData: [String: Any] = [
            "id": UUID().uuidString,
            "type": "like",
            "fromUserId": likerId,
            "fromUserName": likerName,
            "fromUserProfilePictureUrl": likerProfilePictureUrl,
            "postId": postId,
            "postTitle": postTitle,
            "timestamp": Date(),
            "read": false
        ]
        sendNotification(to: postOwnerId, notificationData: notificationData)
        scheduleNotificationForUser(userId: postOwnerId, title: "Like on your post", body: "\(likerName) liked your post \"\(postTitle)\"", triggerTime: 1)
    }
}

//sends the iOS notification
func scheduleNotificationForUser(userId: String, title: String, body: String, triggerTime: TimeInterval) {
    let content = UNMutableNotificationContent()
    content.title = title
    content.body = body
    content.sound = .default

    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: triggerTime, repeats: false)

    //create request
    let request = UNNotificationRequest(identifier: "\(userId)-\(UUID().uuidString)", content: content, trigger: trigger)

    //add the request to the notification center
    UNUserNotificationCenter.current().add(request) { error in
        if let error = error {
            print("Error scheduling notification: \(error)")
        } else {
            print("Notification scheduled for user \(userId) in \(triggerTime) seconds")
        }
    }
}
