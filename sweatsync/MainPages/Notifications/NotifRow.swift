import SwiftUI
import Firebase

struct NotifRow: View {
    let notification: Notification
    
    @State private var profileImage: UIImage? = nil
    @State private var notificationsEnabled = true
        
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Profile Picture
            if let profileImage = profileImage {
                Image(uiImage: profileImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            } else {
                Color.gray
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            }
            // Notification Details
            VStack(alignment: .leading, spacing: 8) {
                // Main Text
                Text(mainText)
                    .font(.custom(Theme.bodyFont, size: 17))
                    .foregroundColor(.white)

                // Timestamp
                Text(notification.timestamp, style: .time)
                    .font(.custom(Theme.bodyFont, size: 13))
                    .foregroundColor(Theme.primaryColor)
            }
            Spacer()
        }
        .padding()
        .background(notification.read ? Theme.secondaryColor : Theme.lightGray)
        .cornerRadius(12)
        .onAppear {
            fetchProfileImage()
        }
    }

    private var mainText: String {
        switch notification.type {
        case "like":
            return "\(notification.fromUserName) liked your post \"\(notification.postTitle)\""
        case "comment":
            return "\(notification.fromUserName) commented: \"\(notification.content ?? "")\" on your post \"\(notification.postTitle)\""
        case "follow":
            return "\(notification.fromUserName) sent you a follow request"
        default:
            return "\(notification.fromUserName) interacted with you"
        }
    }
    
    private func fetchProfileImage() {
        let db = Firestore.firestore()
        
        db.collection("users").document(notification.fromUserId).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching profile image: \(error)")
                return
            }
            
            guard let data = snapshot?.data(),
                  let base64String = data["profileImageBase64"] as? String,
                  let imageData = Data(base64Encoded: base64String),
                  let image = UIImage(data: imageData) else {
                print("Failed to decode image data")
                return
            }
            
            self.profileImage = image
        }
    }
}
