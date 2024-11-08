//
//  HomeScreen.swift
//  sweatsync
//
//  Created by aarushi chitagi on 10/14/24.
//
import FirebaseAuth
import SwiftUI
import Firebase

struct HomeScreenView: View {
    @State private var userName: String = ""
    @State private var posts: [Post] = []
    @State private var isLoading = true
    @State private var profileImage: UIImage? = nil
    
    var body: some View {
        NavigationView{
            VStack(spacing: 20) {
                // Profile Header
                HStack {
                    if let profileImage = profileImage {
                        Image(uiImage: profileImage)
                            .resizable()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(Color(red: 208/255, green: 247/255, blue: 147/255))
                    }
                    
                    
                    VStack(alignment: .leading) {
                        Text("Hi, \(userName)")
                            .font(.title3)
                            .bold()
                            .foregroundColor(.white)
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    self.getUser()
                                    fetchPosts()
                                }
                            }
                        
                        Text("1 workout logged this week")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    NavigationLink(destination: SearchScreenView()) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Color(red: 208/255, green: 247/255, blue: 147/255))
                            .font(.title)
                    }
 
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                // Post Feed
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                } else {
                    List($posts) { $post in
                        WorkoutPostCard(post: $post)
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.black)
                    }
                    .listStyle(.plain)
                }
                
                Spacer()
            }
            .background(Color.black.ignoresSafeArea())
        }
    }

    func getUser() {
        guard let user = Auth.auth().currentUser else {
            print("User not logged in")
            print("here")
            return
        }

        let userId = user.uid
        let db = Firestore.firestore()

        db.collection("users").document(userId).getDocument { document, error in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
            } else if let document = document, document.exists {
                if let fetchedName = document.data()?["preferredName"] as? String {
                    self.userName = fetchedName
                } else {
                    print("Error fetching preferred name")
                }
                
                if let base64ImageString = document.data()?["profileImageBase64"] as? String,
                   let imageData = Data(base64Encoded: base64ImageString),
                   let image = UIImage(data: imageData) {
                    self.profileImage = image
                }
            }
        }
    }

    func fetchPosts() {
        guard let user = Auth.auth().currentUser else {
            print("User not logged in")
            return
        }

        let db = Firestore.firestore()
        db.collection("users").document(user.uid).collection("posts").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching posts: \(error.localizedDescription)")
                self.isLoading = false
                return
            }

            if let documents = snapshot?.documents {
                self.posts = documents.compactMap { document in
                    var exercises: [Exercise] = []
                    if let exerciseArray = document.data()["exercises"] as? [[String: Any]] {
                        exercises = exerciseArray.compactMap { data in
                            let exercise = Exercise()
                            exercise.exerciseType = data["exerciseType"] as? String ?? ""
                            exercise.exerciseName = data["exerciseName"] as? String ?? ""
                            exercise.warmUpSets = (data["warmUpSets"] as? [[String: String]])?.map { ($0["weight"]!, $0["reps"]!) } ?? []
                            exercise.workingSets = (data["workingSets"] as? [[String: String]])?.map { ($0["weight"]!, $0["reps"]!) } ?? []
                            exercise.notes = data["notes"] as? String ?? ""
                            return exercise
                        }
                    }
                    return Post(id: document.documentID, templateName: document.data()["templateName"] as? String ?? "", exercises: exercises)
                }
            }

            self.isLoading = false
        }
    }
}




struct HomeScreenPreview: PreviewProvider {
    static var previews: some View {
        HomeScreenView()
    }
}
