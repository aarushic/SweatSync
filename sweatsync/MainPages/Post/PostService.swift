//
//  PostService.swift
//  sweatsync
//
//  Created by Ashwin on 12/1/24.
//

import Foundation
import Firebase
import UIKit

class PostService {
    // Fetch posts for a specific user and optionally their following users
    static func fetchPosts(userId: String, includeFollowing: Bool, completion: @escaping ([Post], Error?) -> Void) {
        let db = Firestore.firestore()
        var allPosts: [Post] = []
        let group = DispatchGroup()

        func fetchUserPosts(for userId: String, userName: String) {
            group.enter()
            db.collection("users").document(userId).collection("posts").getDocuments { snapshot, error in
                guard let documents = snapshot?.documents else {
                    group.leave()
                    return
                }
                for document in documents {
                    group.enter()
                    mapPost(from: document.data(), documentId: document.documentID, userId: userId, userName: userName) { post in
                        if let post = post {
                            allPosts.append(post)
                        }
                        group.leave()
                    }
                }
                group.leave()
            }
        }

        // Fetch current user's posts
        group.enter()
        db.collection("users").document(userId).getDocument { document, error in
            guard let document = document, document.exists,
                  let userName = document.data()?["preferredName"] as? String else {
                group.leave()
                return
            }
            fetchUserPosts(for: userId, userName: userName)
            group.leave()
        }

        if includeFollowing {
            // Fetch posts from followed users
            db.collection("users").document(userId).collection("following").getDocuments { snapshot, error in
                guard let following = snapshot?.documents.map({ $0.documentID }) else {
                    group.notify(queue: .main) {
                        completion(allPosts, nil)
                    }
                    return
                }

                for followedUserId in following {
                    group.enter()
                    db.collection("users").document(followedUserId).getDocument { document, error in
                        guard let document = document, document.exists,
                              let userName = document.data()?["preferredName"] as? String else {
                            group.leave()
                            return
                        }
                        fetchUserPosts(for: followedUserId, userName: userName)
                        group.leave()
                    }
                }
            }
        }

        group.notify(queue: .main) {
            completion(allPosts.sorted(by: { $0.timestamp > $1.timestamp }), nil)
        }
    }

    // Map Firestore post data to a `Post` object
    static func mapPost(from data: [String: Any], documentId: String, userId: String, userName: String, completion: @escaping (Post?) -> Void) {
        var exercises: [Exercise] = []

        // Map exercises
        if let exerciseArray = data["exercises"] as? [[String: Any]] {
            exercises = exerciseArray.compactMap { exerciseData in
                let exercise = Exercise()
                exercise.exerciseType = exerciseData["exerciseType"] as? String ?? ""
                exercise.exerciseName = exerciseData["exerciseName"] as? String ?? ""

                if exercise.exerciseType == "Sprints" {
                    exercise.distance = exerciseData["distance"] as? String ?? ""
                    exercise.time = exerciseData["time"] as? String ?? ""
                } else {
                    exercise.warmUpSets = (exerciseData["warmUpSets"] as? [[String: String]])?.compactMap {
                        guard let weight = $0["weight"], let reps = $0["reps"] else { return nil }
                        return (weight, reps)
                    } ?? []

                    exercise.workingSets = (exerciseData["workingSets"] as? [[String: String]])?.compactMap {
                        guard let weight = $0["weight"], let reps = $0["reps"] else { return nil }
                        return (weight, reps)
                    } ?? []
                }

                exercise.notes = exerciseData["notes"] as? String ?? ""
                return exercise
            }
        }

        let timestamp = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
        let templateImageUrl = data["templateImageUrl"] as? String ?? ""
        let taggedUser = data["taggedUser"] as? String ?? ""

        var post = Post(
            id: documentId,
            userId: userId,
            templateName: data["templateName"] as? String ?? "",
            templateImageUrl: templateImageUrl,
            exercises: exercises,
            userName: userName,
            timestamp: timestamp,
            taggedUser: taggedUser
        )

        let group = DispatchGroup()

        // Fetch likes
        group.enter()
        fetchLikes(for: post) { likes in
            post.likes = likes
            group.leave()
        }

        // Fetch comments
        group.enter()
        fetchComments(for: post) { comments in
            post.comments = comments
            group.leave()
        }

        group.notify(queue: .main) {
            completion(post)
        }
    }

    // Fetch likes for a post
    private static func fetchLikes(for post: Post, completion: @escaping (Set<String>) -> Void) {
        let db = Firestore.firestore()
        let postRef = db.collection("users").document(post.userId)
            .collection("posts").document(post.id)

        postRef.getDocument { snapshot, error in
            guard let data = snapshot?.data(),
                  let likesArray = data["likes"] as? [String] else {
                completion([])
                return
            }

            completion(Set(likesArray))
        }
    }

    // Fetch comments for a post
    private static func fetchComments(for post: Post, completion: @escaping ([Post.Comment]) -> Void) {
        let db = Firestore.firestore()
        db.collection("users").document(post.userId).collection("posts")
            .document(post.id).collection("comments")
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents else {
                    completion([])
                    return
                }

                let comments = documents.compactMap { doc -> Post.Comment? in
                    guard let userId = doc["userId"] as? String,
                          let userName = doc["userName"] as? String,
                          let commenterId = doc["commenterId"] as? String,
                          let content = doc["content"] as? String,
                          let timestamp = (doc["timestamp"] as? Timestamp)?.dateValue() else {
                        return nil
                    }
                    return Post.Comment(
                        id: doc.documentID,
                        userId: userId,
                        userName: userName,
                        commenterId: commenterId,
                        content: content,
                        timestamp: timestamp
                    )
                }
                completion(comments)
            }
    }
}
