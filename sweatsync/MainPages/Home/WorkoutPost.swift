//
//  WorkoutPost.swift
//  sweatsync
//
//  Created by aarushi chitagi on 10/14/24.
//


import FirebaseAuth
import SwiftUI
import Firebase

struct WorkoutPostCard: View {
    @Binding var post: Post
    @State private var isExpanded: Bool = false
    @State private var isCommentExpanded: Bool = false
    @State private var likeCount: Int
    @State private var newCommentText: String = ""
    
    init(post: Binding<Post>) {
        _post = post
        _likeCount = State(initialValue: post.wrappedValue.likes)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Post Header (User Info)
            HStack {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(Color(red: 208/255, green: 247/255, blue: 147/255)) // Light green
                
                VStack(alignment: .leading) {
                    Text("Person Name")
                        .font(.headline)
                        .foregroundColor(.white)

                    HStack {
                        Text("Location, City")
                            .font(.subheadline)
                            .foregroundColor(.gray)

                        Spacer()

                        Text("2:55:00 PM")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }

                Spacer()

                // Menu Icon (3 dots)
                Button(action: {
                    // Menu action
                }) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal)
            .padding(.top, 10)

            Text(post.templateName)
                .font(.headline)
                .foregroundColor(.white)
                .padding()
            
            // Post Image
            Image("test-image") // Replace with actual asset image or URL
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .cornerRadius(15)
                .padding(.horizontal)
            
            // Like and Comment section
            HStack {
                //Like Button
                Button(action: {
                    likePost()
                }) {
                    Image(systemName: "hand.thumbsup.fill")
                        .foregroundColor(Theme.primaryColor)
                }
                .buttonStyle(BorderlessButtonStyle())
                Text("\(likeCount) likes")
                    .foregroundColor(.white)
                
                Spacer()
                
                //Comment Button
                Button(action: {
                    isCommentExpanded.toggle()
                }) {
                    Image(systemName: "text.bubble.fill")
                        .foregroundColor(Theme.primaryColor)
                }
                .buttonStyle(BorderlessButtonStyle())
                Text("\(post.comments.count) comments")
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
            
            // Expandable Exercise Details
            if isExpanded {
                ForEach(post.exercises) { exercise in
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
                        
                        VStack(alignment: .leading) {
                            Text("Warm-Up Sets:")
                                .font(.custom(Theme.bodyFont2, size: 13))
                                .foregroundColor(.white)
                                .padding(.bottom, 1)
                            ForEach(exercise.warmUpSets, id: \.0) { set in
                                Text("Weight: \(set.0), Reps: \(set.1)")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.bottom, 4)
                       
                        VStack(alignment: .leading) {
                            Text("Working Sets:")
                                .font(.custom(Theme.bodyFont2, size: 13))
                                .foregroundColor(.white)
                                .padding(.bottom, 1)
                            ForEach(exercise.workingSets, id: \.0) { set in
                                Text("Weight: \(set.0), Reps: \(set.1)")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.bottom, 4)
                        
                        if !exercise.notes.isEmpty {
                            Text("Notes: \(exercise.notes)")
                                .font(.custom(Theme.bodyFont2, size: 13))
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                }
            }
            
            // Toggle Button to expand/collapse
            Button(action: {
                isExpanded.toggle()
//                withAnimation {
//                    isExpanded.toggle()
//                }
            }) {
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
        .background(Color(red: 42/255, green: 42/255, blue: 42/255)) // Dark card background
        .cornerRadius(20)
        .padding(.horizontal)
        .padding(.vertical, 25)
    }
    
    private func likePost() {
        likeCount += 1
        let db = Firestore.firestore()
        
        db.collection("users").document("currentUserId").collection("posts").document(post.id).updateData([
            "likes": likeCount
        ]) { error in
            if let error = error {
                print("Error updating likes: \(error.localizedDescription)")
            }
        }
    }
    
    // Function to add a new comment
    private func addComment() {
        guard !newCommentText.isEmpty else { return }

        let db = Firestore.firestore()
        let commentData: [String: Any] = [
            "id": UUID().uuidString,
            "userId": "currentUserId", // Replace with actual user ID
            "userName": "Current User", // Replace with actual user name
            "content": newCommentText,
            "timestamp": Date()
        ]
        
        db.collection("users").document("currentUserId").collection("posts").document(post.id).collection("comments").addDocument(data: commentData) { error in
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


struct Post: Identifiable {
    let id: String
    var templateName: String
    var exercises: [Exercise]
    var likes: Int = 0
    var comments: [Comment] = []
    
    struct Comment: Identifiable {
        let id: String
        let userId: String
        let userName: String
        let content: String
        let timestamp: Date
    }
}

//struct WorkoutPostCard_Previews: PreviewProvider {
//    static var previews: some View {
//        WorkoutPostCard()
//    }
//}


