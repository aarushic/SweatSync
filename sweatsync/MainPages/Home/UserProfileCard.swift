//
//  UserProfileCard.swift
//  sweatsync
//
//  Created by Ashwin on 11/11/24.
//

import Firebase
import FirebaseFirestore
import SwiftUI

struct UserProfileCardView: View {
    let user: User
    @Binding var isFollowing: Bool
    let action: () -> Void
    @State private var profileImage: UIImage? = nil

    var body: some View {
        HStack {
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
            
            VStack(alignment: .leading) {
                Text(user.preferredName)
                    .font(.custom(Theme.bodyFont, size: 18))
                    .foregroundColor(.white)
                
                Text(isFollowing ? "Following" : "Not Following")
                    .font(.custom(Theme.bodyFont, size: 14))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(action: action) {
                Text(isFollowing ? "Unfollow" : "Follow")
                    .font(.custom(Theme.bodyFont, size: 16))
                    .foregroundColor(isFollowing ? .white : Theme.secondaryColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(isFollowing ? Color.red : Theme.primaryColor)
                    .cornerRadius(10)
            }
            .buttonStyle(.borderless)
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
        .onAppear {
            fetchProfileImage()
        }
        .onChange(of: user.id) { newValue in
            fetchProfileImage()
        }
    }

    private func fetchProfileImage() {
        let db = Firestore.firestore()
        
        db.collection("users").document(user.id).getDocument { snapshot, error in
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
