//
//  WorkoutPostCard.swift
//  sweatsync
//
//  Created by Ashwin on 11/9/24.
//

import FirebaseAuth
import SwiftUI
import Firebase

struct WorkoutPostCard: View {
    @Binding var post: Post
    var currUserName: String
    var currUserId: String
    
    @State private var isExpanded = false
    @State private var isCommentExpanded = false
    @State private var newCommentText = ""
    @State private var navigateToProfile = false
    
    @State private var notificationsEnabled: Bool = true
    @State private var commentsDisabled: Bool = false
    
    @State private var showTag = false
    
    init(post: Binding<Post>, currUserName: String, currUserId: String) {
        self._post = post
        self.currUserName = currUserName
        self.currUserId = currUserId
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            PostHeaderView(post: post)
                .onTapGesture {
                    navigateToProfile = true
                    print("navigateToProfile set to \(navigateToProfile)")
                }
            PostContent()
            LikeAndCommentSection()
            if isExpanded { ExerciseDetailsSection() }
            if isCommentExpanded { CommentsSection() }
            ExpandCollapseButton()
        }
        .background(Theme.secondaryColor)
        .cornerRadius(20)
        .padding(.horizontal)
        .padding(.vertical, 25)
        
        .onAppear {
            Task {
                commentsDisabled = await fetchCommentsDisabled(userId: currUserId)
                notificationsEnabled = await fetchNotificationsEnabled(userId: currUserId)
            }
        }
        .background(
            NavigationLink(
                destination: ProfileScreen(user: User(id: post.userId, preferredName: post.userName, profilePictureUrl: ""), settings: false),
                isActive: $navigateToProfile
            ) {
                EmptyView()
            }
            .hidden()
        )
        .onTapGesture {
            dismissKeyboard()
        }
    }
    
    //components
    struct PostHeaderView: View {
        var post: Post
        @State private var profileImage: UIImage? = nil

        var body: some View {
            HStack {
                HStack {
                    if let profileImage = profileImage {
                        Image(uiImage: profileImage)
                            .resizable()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(Theme.primaryColor)
                    }
                    
                    HStack {
                        Text(post.userName)
                            .font(.custom(Theme.headingFont, size: 19))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text(formatTimestamp(post.timestamp))
                            .font(.custom(Theme.bodyFont, size: 17))
                            .foregroundColor(.gray)
                    }
                }
                .padding([.horizontal, .vertical], 15)
                Spacer()
            }
            .contentShape(Rectangle())
            .background(Theme.secondaryColorOp)
            .onAppear {
                fetchProfileImage()
            }
        }

        private func fetchProfileImage() {
            let db = Firestore.firestore()
            let userId = post.userId
            
//            print("tagged \(post.taggedUser)")
            
            db.collection("users").document(userId).getDocument { snapshot, error in
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
    
    private func PostContent() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(post.templateName)
                .font(.custom(Theme.headingFont, size: 18))
                .foregroundColor(.white)
                .padding()
            
            if !post.templateImageUrl.isEmpty,
               let imageData = Data(base64Encoded: post.templateImageUrl),
               let uiImage = UIImage(data: imageData) {
                ZStack(alignment: .bottomTrailing) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .cornerRadius(15)
                        .padding(.horizontal)
                        .onTapGesture {
                            withAnimation {
                                showTag.toggle()
                            }
                        }
                    
                    if let taggedUser = post.taggedUser, !taggedUser.isEmpty {
                        // Profile icon
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .padding(10)
                            .padding(.trailing, 20)
                            .foregroundColor(Theme.primaryColor)
                    
                        
                        // Tagged user text (conditionally visible)
                        if showTag {
                            Button(action: {
                                navigateToProfile = true
                            }) {
                                Text("\(taggedUser)")
                                    .font(.custom(Theme.bodyFont, size: 12))
                                    .padding(8)
                                    .background(Color.black.opacity(0.7))
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                                    .padding(30)
                                    .padding(.bottom, 10)
                            }
                        }
                    }
                }
            } else {
                Image("test-image")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .cornerRadius(15)
                    .padding(.horizontal)
                    .onTapGesture {
                        withAnimation {
                            showTag.toggle()
                        }
                    }
            }
        }
    }


    private func LikeAndCommentSection() -> some View {
        HStack {
            LikeButton()
            Text("\(post.likes.count) likes")
                .font(.custom(Theme.bodyFont, size: 15))
                .foregroundColor(.white)
            
            Spacer()
            
            if !commentsDisabled {
                CommentButton()
                Text("\(post.comments.count) comments")
                    .font(.custom(Theme.bodyFont, size: 15))
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal)
    }

    private func CommentsSection() -> some View {
        VStack(alignment: .leading) {
            ForEach(post.comments) { comment in
                CommentRow(comment: comment)
            }
            NewCommentInput()
        }
        .padding()
        .background(Theme.secondaryColorOp)
        .cornerRadius(10)
    }

    private func ExerciseDetailsSection() -> some View {
        ForEach(post.exercises) { exercise in
            ExerciseDetailsRow(exercise: exercise)
        }
        .padding()
        
    }

    private func ExpandCollapseButton() -> some View {
        Button(action: { isExpanded.toggle() }) {
            Text(isExpanded ? "Hide Details" : "View Workout Details")
                .font(.custom(Theme.bodyFont, size: 13))
                .frame(width: 170, height: 30)
                .background(Theme.primaryColor)
                .cornerRadius(10)
                .foregroundColor(Theme.secondaryColor)
        }
        .padding()
        .buttonStyle(BorderlessButtonStyle())
    }

    //subcomponents
    private func LikeButton() -> some View {
        let imageType = (self.post.likes.contains(currUserId)) ? "hand.thumbsup.fill" : "hand.thumbsup"
        return Button(action: likePost) {
            Image(systemName: imageType)
                .foregroundColor(Theme.primaryColor)
        }
        .buttonStyle(BorderlessButtonStyle())
    }

    private func CommentButton() -> some View {
        Button(action: { isCommentExpanded.toggle() }) {
            Image(systemName: "text.bubble.fill")
                .foregroundColor(Theme.primaryColor)
        }
        .buttonStyle(BorderlessButtonStyle())
    }

    private func CommentRow(comment: Post.Comment) -> some View {
        HStack(alignment: .top) {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundColor(Theme.primaryColor)
            
            VStack(alignment: .leading) {
                Text(comment.userName)
                    .font(.custom(Theme.bodyFont, size: 16))
                    .foregroundColor(.white)
                Text(comment.content)
                    .font(.custom(Theme.bodyFont, size: 14))
                    .foregroundColor(.gray)
                Text(formatTimestamp(comment.timestamp))
                    .font(.custom(Theme.bodyFont, size: 13))
                    .foregroundColor(.gray)
            }
            .padding(.bottom)
            
            Spacer()
        }
        .padding(.vertical, 4)
    }

    private func NewCommentInput() -> some View {
        HStack {
            TextField("Add a comment...", text: $newCommentText)
                .font(.custom(Theme.bodyFont, size: 13))
                .foregroundColor(.white)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .padding(.vertical, 6)
            
            Button(action: addComment) {
                Image(systemName: "paperplane.fill")
                    .foregroundColor(Theme.primaryColor)
            }
        }
        .padding(.horizontal, 2)
    }

    private func ExerciseDetailsRow(exercise: Exercise) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                // Exercise Name and Type
                VStack(alignment: .leading, spacing: 2) {
                    Text(exercise.exerciseName)
                        .font(.custom(Theme.headingFont, size: 15))
                        .foregroundColor(.white)
                    Text("Type: \(exercise.exerciseType)")
                        .font(.custom(Theme.bodyFont, size: 14))
                        .foregroundColor(.gray)
                }
                .padding(.bottom, 6)
                
                if (exercise.exerciseType == "Sprints") {
                    // Warm-Up and Working Sets
                    Text("Sprint Details")
                        .font(.custom(Theme.bodyFont, size: 14))
                        .foregroundColor(.white)
                        .bold()
                    
                    HStack(alignment: .top, spacing: 16) {
                        Text(exercise.distance != nil ? "Distance: \(exercise.distance) meters" : "Distance: N/A")
                            .font(.custom(Theme.bodyFont, size: 13))
                            .foregroundColor(.gray)
                        
                        Text(exercise.time != nil ? "Time: \(exercise.time) seconds" : "Time: N/A")
                            .font(.custom(Theme.bodyFont, size: 13))
                            .foregroundColor(.gray)
                    }
                }
                else {
                    // Warm-Up and Working Sets
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach([("Warm-Up Sets", exercise.warmUpSets), ("Working Sets", exercise.workingSets)], id: \.0) { title, sets in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(title)
                                    .font(.custom(Theme.bodyFont, size: 14))
                                    .foregroundColor(.white)
                                    .bold()
                                
                                if sets.isEmpty {
                                    Text("No sets available")
                                        .font(.custom(Theme.bodyFont, size: 13))
                                        .foregroundColor(.gray)
                                } else {
                                    ForEach(Array(sets.enumerated()), id: \.0) { index, set in
                                        Text("Weight: \(set.0) lbs, Reps: \(set.1)")
                                            .font(.custom(Theme.bodyFont, size: 13))
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            .cornerRadius(8)
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                // Notes Section
                if !exercise.notes.isEmpty {
                    Text("Notes:")
                        .font(.custom(Theme.bodyFont, size: 14))
                        .foregroundColor(.white)
                        .bold()
                    Text(exercise.notes)
                        .font(.custom(Theme.bodyFont, size: 13))
                        .foregroundColor(.gray)
                }
            }
            .cornerRadius(10)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Theme.secondaryColorOp)
        .padding(.horizontal, 2)
        .cornerRadius(10)
    }
    
    private func likePost() {
        let db = Firestore.firestore()
        let postRef = db.collection("users").document(post.userId)
            .collection("posts").document(post.id)

        if post.likes.contains(currUserId) {
            let oldLikes = post.likes
            post.likes.remove(currUserId)
            postRef.updateData([
                "likes": FieldValue.arrayRemove([currUserId])
            ]) { error in
                if let error = error {
                    print("Error removing like: \(error.localizedDescription)")
                    post.likes = oldLikes
                }
            }
        } else {
            let oldLikes = post.likes
            post.likes.insert(currUserId)
            postRef.updateData([
                "likes": FieldValue.arrayUnion([currUserId])
            ]) { error in
                if let error = error {
                    print("Error adding like: \(error.localizedDescription)")
                    post.likes = oldLikes
                } else {
                    if notificationsEnabled {
                        sendLikeNotification(to: post.userId, by: currUserId, postId: post.id, postTitle: post.templateName)
                    }
                }
            }
        }
        Firestore.firestore()
                .collection("users").document(post.userId)
                .collection("posts").document(post.id)
                .getDocument { snapshot, _ in
                    post.likes = Set((snapshot?.data()?["likes"] as? [String]) ?? [])
                }
    }
    
    private func addComment() {
        guard !newCommentText.isEmpty else { return }
        dismissKeyboard()

        let commentData: [String: Any] = [
            "id": UUID().uuidString,
            "userId": post.userId,
            "userName": currUserName,
            "commenterId": currUserId,
            "content": newCommentText,
            "timestamp": Date()
        ]
        
        Firestore.firestore().collection("users").document(post.userId).collection("posts")
            .document(post.id).collection("comments")
            .addDocument(data: commentData) { error in
                if let error = error {
                    print("Error adding comment: \(error.localizedDescription)")
                } else {
                    post.comments.append(Post.Comment(
                        id: commentData["id"] as! String,
                        userId: commentData["userId"] as! String,
                        userName: commentData["userName"] as! String,
                        commenterId: commentData["commenterId"] as! String,
                        content: commentData["content"] as! String,
                        timestamp: Date()
                    ))

                    if notificationsEnabled && currUserId != post.userId {
                        sendCommentNotification(
                            to: post.userId,
                            by: currUserId,
                            content: commentData["content"] as! String,
                            postId: post.id,
                            postTitle: post.templateName
                        )
                    }

                }
            }
        newCommentText = ""
    }
}

//format timestamp
func formatTimestamp(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter.string(from: date)
}
