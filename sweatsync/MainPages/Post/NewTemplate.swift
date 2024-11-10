import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import PhotosUI
import FirebaseStorage

struct NewTemplateView: View {
    @State private var templateName: String = ""
    @State private var curExerciseId: Int = 1
    @State private var saveAsTemplate: Bool = false
    @State private var isShowingHomeScreen: Bool = false
    @State var exercises: [Int: Exercise] = [:]
    @State private var forceRefresh = UUID()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    TemplateNameInput(templateName: $templateName)
                    
                    Toggle("Save as Template", isOn: $saveAsTemplate)
                       .padding()
                       .background(.white)
                       .cornerRadius(10)
                    
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
                    
                    PostButton(templateName: $templateName, exercises: $exercises, isShowingHomeScreen: $isShowingHomeScreen, saveAsTemplate: $saveAsTemplate)

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

func postTemplateToFirebase(templateName: String, exercises: [Int: Exercise], saveAsTemplate: Bool, completion: @escaping (Bool) -> Void) {
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
        ] as [String: Any]
    }

    templateData["exercises"] = exerciseArray

    // Add to posts collection for the user's feed
    db.collection("users").document(userId).collection("posts").addDocument(data: templateData) { error in
        if let error = error {
            print("Error posting template: \(error.localizedDescription)")
            completion(false)
        } else {
            print("Template posted successfully to posts.")
            
            // If saveAsTemplate is true, save to templates collection as well
            if saveAsTemplate {
                db.collection("users").document(userId).collection("templates").addDocument(data: templateData) { error in
                    if let error = error {
                        print("Error saving template to templates collection: \(error.localizedDescription)")
                        completion(false)
                    } else {
                        print("Template saved successfully to templates collection.")
                        completion(true)
                    }
                }
            } else {
                completion(true)
            }
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

