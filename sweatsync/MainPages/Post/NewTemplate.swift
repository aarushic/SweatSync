import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import PhotosUI
import FirebaseStorage

struct NewTemplateView: View {
    @State private var templateName: String = ""
    @State private var templateType: String = ""
    @State private var templateImageUrl: String = ""

    @State private var curExerciseId: Int = 1
    @State private var saveAsTemplate: Bool = false
    @State private var errorMessage: String?
    @State private var isShowingHomeScreen: Bool = false
    @State var exercises: [Int: Exercise] = [:]
    @State private var forceRefresh = UUID()
    
    @State private var photo: PhotosPickerItem?
    @State private var decodedImage: UIImage?
    @State private var showImagePicker: Bool = false
    
    @State private var taggedUser: String = ""

    var body: some View {
            ScrollView {
                VStack {
                    HStack {
                        TemplateNameInput(templateName: $templateName)
                            .font(.custom(Theme.bodyFont, size: 16))
                        
                        Button(action: { showImagePicker = true }) {
                            Image(systemName: "camera.fill")
                                .resizable()
                                .frame(width: 40, height: 30)
                                .foregroundColor(Theme.primaryColor)
                                .padding(15)
                                .background(Circle().fill(Theme.secondaryColor))
                                .shadow(radius: 2)
                        }
                    }
                    
                    if let image = decodedImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 150, height: 150)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    
                    Toggle("Save as Template", isOn: $saveAsTemplate)
                        .font(.custom(Theme.bodyFont, size: 14))
                       .padding(.horizontal)
                       .padding(.vertical, 6)
                       .background(Color.white)
                       .cornerRadius(10)
                       .tint(Theme.secondaryColor)
                       .frame(height: 40)
                    
                    TextField("Tag someone (email)", text: $taggedUser)
                        .font(.custom(Theme.bodyFont, size: 14))
                       .padding(.horizontal)
                       .padding(.vertical, 6)
                       .background(Color.white)
                       .cornerRadius(10)
                       .tint(Theme.secondaryColor)
                        .textInputAutocapitalization(.never)
                        .onSubmit {
                            dismissKeyboard()
                        }
                    
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
                                .font(.custom(Theme.bodyFont, size: 16))
                            } else {
                                switch exercise.exerciseType {
                                    case "Sprints":
                                        SprintDetailView(exercise: exercise, onDelete: {
                                            exercises.removeValue(forKey: key)
                                            forceRefresh = UUID()
                                        })
                                        
                                    case "Swimming":
                                        SwimmingDetailView(exercise: exercise, onDelete: {
                                            exercises.removeValue(forKey: key)
                                            forceRefresh = UUID()
                                        })
                                        
                                    case "Biking":
                                        BikingDetailView(exercise: exercise, onDelete: {
                                            exercises.removeValue(forKey: key)
                                            forceRefresh = UUID()
                                        })
                                        
                                    default:
                                        ExerciseDetailView(exercise: exercise, onDelete: {
                                            exercises.removeValue(forKey: key)
                                            forceRefresh = UUID()
                                        })
                                    }
                            }
                        }
                    }
                    .id(forceRefresh)
                    
                    AddExerciseButton(curExerciseId: $curExerciseId, exercises: $exercises)
                        .font(.custom(Theme.bodyFont, size: 16))
                    
                    //error message
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding(.top, 10)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        if templateName.isEmpty {
                            errorMessage = "Please enter a post name."
                        } else if decodedImage == nil || templateImageUrl.isEmpty {
                            errorMessage = "Please add a picture."
                        } else if exercises.isEmpty || exercises.values.contains(where: { $0.exerciseName.isEmpty || $0.exerciseType.isEmpty }) {
                            errorMessage = "Please fill in at least one exercise with all required details."
                        } else {
                            //clear error and attempt to post
                            errorMessage = nil
                            postTemplateToFirebase(templateName: templateName, exercises: exercises, saveAsTemplate: saveAsTemplate) { success in
                                if success {
                                    isShowingHomeScreen = true
                                } else {
                                    errorMessage = "Failed to post template. Please try again."
                                }
                            }
                        }
                    }) {
                        Text("Post")
                            .frame(maxWidth: .infinity)
                            .font(.custom(Theme.bodyFont, size: 16))
                            .padding()
                            .background(Theme.secondaryColor)
                            .foregroundColor(Theme.primaryColor)
                            .cornerRadius(10)
                            .padding(.top, 10)
                    }

                    Spacer()
                }
            }
            .padding()
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("New Template")
            .navigationBarTitleDisplayMode(.inline)
            .fullScreenCover(isPresented: $isShowingHomeScreen) {
                TabBarView()
            }
            .photosPicker(isPresented: $showImagePicker, selection: $photo, matching: .images)
            .onChange(of: photo) { newItem in
                Task {
                    if let newItem = newItem {
                        if let data = try? await newItem.loadTransferable(type: Data.self) {
                            decodedImage = UIImage(data: data)
                            templateImageUrl = decodedImage?.jpegData(compressionQuality: 0.5)?.base64EncodedString() ?? ""
                        }
                    }
            }
        }
        .onTapGesture {
            dismissKeyboard()
        }
    }
    
    func postTemplateToFirebase(templateName: String, exercises: [Int: Exercise], saveAsTemplate: Bool, completion: @escaping (Bool) -> Void) {
        guard let user = Auth.auth().currentUser else {
            print("User is not logged in.")
            completion(false)
            return
        }

        let db = Firestore.firestore()
        let userId = user.uid
        let currentDate = Date()

        var templateData: [String: Any] = [
            "templateName": templateName,
            "timestamp": Timestamp(date: currentDate),
            "userId": userId,
            "taggedUser": taggedUser
        ]
        
        if !templateImageUrl.isEmpty {
            templateData["templateImageUrl"] = templateImageUrl
        }
        
        var exerciseArray: [[String: Any]] = []

        for exercise in exercises.values {
            var exerciseDict: [String: Any] = [
                "exerciseType": exercise.exerciseType,
                "exerciseName": exercise.exerciseName,
                "notes": exercise.notes,
                "timestamp": Timestamp(date: currentDate)
            ]
            
            if exercise.exerciseType == "Sprints" {
                exerciseDict["distance"] = exercise.distance
                exerciseDict["time"] = exercise.time
            } else if exercise.exerciseType == "Strength Training" {
                exerciseDict["warmUpSets"] = exercise.warmUpSets.map { ["weight": $0.0, "reps": $0.1] }
                exerciseDict["workingSets"] = exercise.workingSets.map { ["weight": $0.0, "reps": $0.1] }
            } else if exercise.exerciseType == "Swimming" {
                exerciseDict["strokeType"] = exercise.strokeType
                exerciseDict["laps"] = exercise.laps
                exerciseDict["swimDistance"] = exercise.swimDistance
                exerciseDict["swimDuration"] = exercise.swimDuration
            } else if exercise.exerciseType == "Biking" {
                exerciseDict["bikeDistance"] = exercise.bikeDistance
                exerciseDict["bikeDuration"] = exercise.bikeDuration
                exerciseDict["averageSpeed"] = exercise.averageSpeed
                exerciseDict["elevationGain"] = exercise.elevationGain
            }
        
            exerciseArray.append(exerciseDict)
        }

        templateData["exercises"] = exerciseArray
        
        updateStreak(user)

        db.collection("users").document(userId).collection("posts").addDocument(data: templateData) { error in
                if let error = error {
                    print("Error posting template: \(error.localizedDescription)")
                    completion(false)
                } else {
                    print("Template posted successfully to posts.")
                    updateLastPostDate(user)

                    if saveAsTemplate {
                        db.collection("users").document(userId).collection("templates").addDocument(data: templateData) { error in
                            if let error = error {
                                print("Error saving template to templates collection: \(error.localizedDescription)")
                                completion(false)
                            } else {
                                //increase count and update achievements
                                db.collection("users").document(userId).setData([
                                    "workoutCount": FieldValue.increment(Int64(1))
                                ], merge: true) { error in
                                    if let error = error {
                                        print("Error updating workout count: \(error.localizedDescription)")
                                    } else {
                                        checkAndUpdateAchievements(for: user)
                                    }
                                }
                                print("Template posted successfully.")
                                completion(true)
                            }
                        }
                    } else {
                        db.collection("users").document(userId).setData([
                            "workoutCount": FieldValue.increment(Int64(1))
                        ], merge: true) { error in
                            if let error = error {
                                print("Error updating workout count: \(error.localizedDescription)")
                            } else {
                                print("workout count")
                                checkAndUpdateAchievements(for: user)
                            }
                        }
                        completion(true)
                    }
                }
            }
    }

}

//update user's lastPostDate field
func updateLastPostDate(_ user : UserInfo) {
    let db = Firestore.firestore()
    let currentDate = Date()
    db.collection("users").document(user.uid).setData(["lastPostDate": Timestamp(date: currentDate)], merge: true) {
        error in
        if let error = error {
            print("Error adding date: \(error.localizedDescription)")
        }
        else {
            print("Updated lastPostDate successfully")
        }
    }
}

//update a user's currentStreak
func updateStreak(_ user: UserInfo) {
    let db = Firestore.firestore()
    let currentDate = Date()
    let userRef = db.collection("users").document(user.uid)
    
    userRef.getDocument { document, error in
        if let document = document, document.exists {
            let lastPostDate = document.data()?["lastPostDate"] as? Timestamp ?? Timestamp(date: Date(timeIntervalSince1970: 0))
            let currentStreak = document.data()?["currentStreak"] as? Int ?? 1
            
            let calendar = Calendar.current
            let daysSinceLastPost = calendar.dateComponents([.day], from: lastPostDate.dateValue(), to: currentDate).day ?? 0
            
            var newStreak = currentStreak
            if daysSinceLastPost == 1 {
                newStreak = currentStreak + 1
            } else if daysSinceLastPost > 1 {
                newStreak = 1
            }
            
            //udate the streak in Firestore
            userRef.setData(["currentStreak": newStreak], merge: true) { error in
                if let error = error {
                    print("Error updating currentStreak: \(error.localizedDescription)")
                } else {
                    print("Updated currentStreak to \(newStreak)")
                }
            }
        }
    }
}

func checkAndUpdateAchievements(for user: UserInfo) {
    let db = Firestore.firestore()
    let userRef = db.collection("users").document(user.uid)
    
    userRef.getDocument { document, error in
        if let document = document, document.exists {
            let workoutCount = document.data()?["workoutCount"] as? Int ?? 0
            var earnedBadges = document.data()?["earnedBadges"] as? [String] ?? []
            
            let newBadges: [String] = [
                (workoutCount >= 1 && !earnedBadges.contains("First Workout")) ? "First Workout" : nil,
                (workoutCount >= 5 && !earnedBadges.contains("5 Workouts")) ? "5 Workouts" : nil,
                (workoutCount >= 10 && !earnedBadges.contains("10 Workouts")) ? "10 Workouts" : nil,
                (workoutCount >= 30 && !earnedBadges.contains("30 Workouts")) ? "30 Workouts" : nil,
                (workoutCount >= 100 && !earnedBadges.contains("100 Workouts")) ? "100 Workouts" : nil
            ].compactMap { $0 }
            
            if !newBadges.isEmpty {
                earnedBadges.append(contentsOf: newBadges)
                userRef.setData(["earnedBadges": earnedBadges], merge: true) { error in
                    if let error = error {
                        print("Error updating badges: \(error.localizedDescription)")
                    } else {
                        print("Updated badges: \(earnedBadges)")
                    }
                }
            }
        }
    }
}
