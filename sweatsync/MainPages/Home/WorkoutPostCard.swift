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
    
    @State private var isExpanded = false
    @State private var isCommentExpanded = false
    @State private var likeCount: Int
    @State private var newCommentText = ""
    @State private var commentCount: Int = 0 

    
    init(post: Binding<Post>, currUserName: String) {
        self._post = post
        self.currUserName = currUserName
        self._likeCount = State(initialValue: post.wrappedValue.likes)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            PostHeaderView()
            PostContent()
            LikeAndCommentSection()
            if isCommentExpanded { CommentsSection() }
            if isExpanded { ExerciseDetailsSection() }
            ExpandCollapseButton()
        }
        .background(Color(red: 42/255, green: 42/255, blue: 42/255))
        .cornerRadius(20)
        .padding(.horizontal)
        .padding(.vertical, 25)
        .onAppear {
            fetchLikes()
            fetchComments()
            commentCount = post.comments.count
        }
    }
    
    
    //components
    private func PostHeaderView() -> some View {
        let user = User(id: post.userId, preferredName: post.userName, profilePictureUrl: "")
        
        return NavigationLink(destination: ProfileScreen(user: user, settings: false)) {
            HStack {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(Theme.primaryColor)
                
                VStack(alignment: .leading) {
                    Text(post.userName).font(.headline).foregroundColor(.white)
                    HStack {
                        Text("Location, City").font(.subheadline).foregroundColor(.gray)
                        Spacer()
                        Text(formatTimestamp(post.timestamp)).font(.subheadline).foregroundColor(.gray)
                    }
                }
                Spacer()
            }
            .padding([.horizontal, .top], 10)
        }
        .buttonStyle(PlainButtonStyle())
    }

    
    private func PostContent() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(post.templateName)
                .font(.headline)
                .foregroundColor(.white)
                .padding()
            
            Image("test-image")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .cornerRadius(15)
                .padding(.horizontal)
        }
    }
    
    private func LikeAndCommentSection() -> some View {
        HStack {
            LikeButton()
            Text("\(likeCount) likes").foregroundColor(.white)
            
            Spacer()
            
            CommentButton()
            Text("\(commentCount) comments").foregroundColor(.white)
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
        .background(Color.gray.opacity(0.1))
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
                .frame(width: 150, height: 30)
                .font(.custom(Theme.headingFont2, size: 14))
                .background(Theme.primaryColor)
                .cornerRadius(10)
                .foregroundColor(Theme.secondaryColor)
        }
        .padding()
        .buttonStyle(BorderlessButtonStyle())
    }
    
    //subcomponents
    private func LikeButton() -> some View {
        Button(action: likePost) {
            Image(systemName: "hand.thumbsup.fill")
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
                Text(comment.userName).font(.custom("Poppins-Regular", size: 14)).foregroundColor(.white)
                Text(comment.content).font(.custom("Poppins-Regular", size: 12)).foregroundColor(.gray)
                Text(formatTimestamp(comment.timestamp)).font(.custom("Poppins-Regular", size: 11)).foregroundColor(.gray)
            }
            .padding(.bottom)
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
    
    private func NewCommentInput() -> some View {
        HStack {
            TextField("Add a comment...", text: $newCommentText)
                .font(.custom("YourFontName", size: 12))
                .foregroundColor(.white)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .padding(.vertical, 6)
            
            Button(action: addComment) {
                Image(systemName: "paperplane.fill").foregroundColor(Theme.primaryColor)
            }
        }
        .padding(.horizontal, 2)
    }
    
    private func ExerciseDetailsRow(exercise: Exercise) -> some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Text(exercise.exerciseName)
                    .font(.custom(Theme.headingFont, size: 15))
                    .foregroundColor(.white)
                Text("Type: \(exercise.exerciseType)")
                    .font(.custom(Theme.bodyFont2, size: 13))
                    .foregroundColor(.gray)
            }
            .padding(.bottom, 4)
            
            ForEach([("Warm-Up Sets:", exercise.warmUpSets), ("Working Sets:", exercise.workingSets)], id: \.0) { title, sets in
                Text(title)
                    .font(.custom(Theme.bodyFont2, size: 13))
                    .foregroundColor(.white)
                ForEach(sets, id: \.0) { set in
                    Text("Weight: \(set.0), Reps: \(set.1)")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                .padding(.bottom, 4)
            }
            
            if !exercise.notes.isEmpty {
                Text("Notes: \(exercise.notes)")
                    .font(.custom(Theme.bodyFont2, size: 13))
                    .foregroundColor(.white)
            }
        }
    }
    
    //helper methods
    private func fetchLikes() {
        Firestore.firestore().collection("users").document(post.userId)
            .collection("posts").document(post.id)
            .getDocument { document, error in
                if let document = document, document.exists, let data = document.data(), let likes = data["likes"] as? Int {
                    likeCount = likes
                } else {
//                    print("Error fetching likes: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
    }
    
    private func likePost() {
        likeCount += 1
        Firestore.firestore().collection("users").document(post.userId)
            .collection("posts").document(post.id)
            .updateData(["likes": likeCount]) { error in
                if let error = error {
                    print("Error updating likes: \(error.localizedDescription)")
                }
            }
    }
    
    private func fetchComments() {
        let db = Firestore.firestore()
        db.collection("users").document(post.userId).collection("posts")
            .document(post.id).collection("comments")
            .getDocuments { snapshot, error in
                guard error == nil, let documents = snapshot?.documents else {
                    print("Error fetching comments: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                post.comments = documents.compactMap { doc in
                    guard let userId = doc["userId"] as? String,
                          let userName = doc["userName"] as? String,
                          let content = doc["content"] as? String,
                          let timestamp = (doc["timestamp"] as? Timestamp)?.dateValue()
                    else { return nil }
                    return Post.Comment(id: doc.documentID, userId: userId, userName: userName, content: content, timestamp: timestamp)
                }
                commentCount = post.comments.count
            }
    }
    
    private func addComment() {
        guard !newCommentText.isEmpty else { return }
        
        let commentData: [String: Any] = [
            "id": UUID().uuidString,
            "userId": post.userId,
            "userName": currUserName,
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
                        content: commentData["content"] as! String,
                        timestamp: Date()
                    ))
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
