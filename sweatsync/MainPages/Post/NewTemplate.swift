import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import PhotosUI
import FirebaseFirestore
import FirebaseStorage

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct NewTemplateView: View {
    @State private var templateName: String = ""
    @State private var curExerciseId: Int = 1
    @State private var isShowingHomeScreen: Bool = false
    @State var exercises: [Int: Exercise] = [:]
    @State private var forceRefresh = UUID()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    TemplateNameInput(templateName: $templateName)
                    Spacer()
                    ForEach(Array(exercises.keys.sorted()), id: \.self) { key in
                        if let exercise = exercises[key] {
                            if exercise.exerciseType.isEmpty {
                                Dropdown(exerciseType: Binding(
                                    get: { exercise.exerciseType },
                                    set: { newType in
                                        exercise.exerciseType = newType
                                        forceRefresh = UUID()
                                    }
                                ))
                            } else {
                                ExerciseDetailView(exercise: exercise, onDelete: {
                                    exercises.removeValue(forKey: key)
                                    forceRefresh = UUID()
                                })
                            }
                        }
                    }
                    .id(forceRefresh)
                    
                    AddExerciseButton(curExerciseId: $curExerciseId, exercises: $exercises)
                    
                    PostButton(templateName: $templateName, exercises: $exercises, isShowingHomeScreen: $isShowingHomeScreen)
                    
                    Spacer()
                }
            }
            .padding()
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("New Template")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $isShowingHomeScreen) {
                HomeScreenView()
            }
        }
    }
}

func postTemplateToFirebase(templateName: String, exercises: [Int: Exercise], completion: @escaping (Bool) -> Void) {
    guard let user = Auth.auth().currentUser else {
        print("User is not logged in.")
        completion(false)
        return
    }

    let db = Firestore.firestore()
    let userId = user.uid
    let currentDate = Date()

    // Template data with a timestamp and exercises array
    var templateData: [String: Any] = [
        "templateName": templateName,
        "timestamp": Timestamp(date: currentDate),
        "userId": userId
    ]

    // Map exercises to dictionaries for storing in Firestore
    let exerciseArray = exercises.values.map { exercise in
        return [
            "exerciseType": exercise.exerciseType,
            "exerciseName": exercise.exerciseName,
            "warmUpSets": exercise.warmUpSets.map { ["weight": $0.0, "reps": $0.1] },
            "workingSets": exercise.workingSets.map { ["weight": $0.0, "reps": $0.1] },
            "notes": exercise.notes,
            "timestamp": Timestamp(date: currentDate)
            // Include image data as Base64 if needed
//            "imageBase64": exercise.selectedImageData?.base64EncodedString() ?? ""
        ] as [String: Any]
    }

    templateData["exercises"] = exerciseArray

    // Add to posts collection for the user's feed
    db.collection("users").document(userId).collection("posts").addDocument(data: templateData) { error in
        if let error = error {
            print("Error posting template: \(error.localizedDescription)")
            completion(false)
        } else {
            print("Template posted successfully.")
            completion(true)
        }
    }
}

struct TemplateNameInput: View {
    @Binding var templateName: String
    
    var body: some View {
        HStack {
            TextField("New Template Name", text: $templateName)
                .textInputAutocapitalization(.words)
                .padding()
                .background(.white)
                .cornerRadius(10)
                .foregroundColor(.black)
                .font(.title3)
        }
        .padding(.top, 10)
    }
}

struct PostButton: View {
    @Binding var templateName: String
    @Binding var exercises: [Int: Exercise]
    @Binding var isShowingHomeScreen: Bool

    var body: some View {
        Button(action: {
            postTemplateToFirebase(templateName: templateName, exercises: exercises) { success in
                if success {
                    print("Template and exercises posted successfully.")
                    isShowingHomeScreen = true
                } else {
                    print("Failed to post template.")
                }
            }
        }) {
            Text("Post")
                .font(.body)
                .foregroundColor(Theme.secondaryColor)
                .padding()
                .background(Theme.primaryColor)
                .cornerRadius(10)
        }
        .padding(.top, 30)
    }
}

// Update streak information
//func updateStreak(userId: String, currentDate: Date) {
//    let db = Firestore.firestore()
//    let userRef = db.collection("users").document(userId)
//    
//    userRef.getDocument { (document, error) in
//        if let document = document, document.exists {
//            let lastPostDate = document.data()?["lastPostDate"] as? Timestamp ?? Timestamp(date: Date(timeIntervalSince1970: 0))
//            let currentStreak = document.data()?["currentStreak"] as? Int ?? 0
//            let highestStreak = document.data()?["highestStreak"] as? Int ?? 0
//
//            let calendar = Calendar.current
//            let daysSinceLastPost = calendar.dateComponents([.day], from: lastPostDate.dateValue(), to: currentDate).day ?? 0
//            
//            var newStreak = daysSinceLastPost == 1 ? currentStreak + 1 : (daysSinceLastPost == 0 ? currentStreak : 1)
//            let newHighestStreak = max(newStreak, highestStreak)
//
//            userRef.updateData([
//                "lastPostDate": Timestamp(date: currentDate),
//                "currentStreak": newStreak,
//                "highestStreak": newHighestStreak
//            ])
//
//            // Grant badge for specific streak milestones (e.g., 7 days)
//            if newStreak == 7 {
//                userRef.collection("badges").document("7DayStreak").setData([
//                    "name": "7-Day Streak",
//                    "dateAchieved": Timestamp(date: currentDate)
//                ])
//            }
//        } else {
//            print("User document does not exist")
//        }
//    }
//}


#Preview {
    NewTemplateView()
}
