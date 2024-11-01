import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct NewTemplateView: View {
    @State private var templateName: String = ""
    @State private var curExerciseId: Int = 1
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
                                        //force refresh when you choose exercise type
                                        forceRefresh = UUID()
                                    }
                                ))
                            } else {
                                ExerciseDetailView(exercise: exercise, onDelete: {
                                    exercises.removeValue(forKey: key)
                                    //refresh when you delete
                                    forceRefresh = UUID()
                                })
                            }
                        }
                    }
                    .id(forceRefresh)
                    
                    AddExerciseButton(curExerciseId: $curExerciseId, exercises: $exercises)
                    
                    PostButton(templateName: $templateName, exercises: $exercises)
                    
                    Spacer()
                }
            }
            .padding()
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("New Template")
            .navigationBarTitleDisplayMode(.inline)
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

struct Dropdown: View {
    @Binding var exerciseType: String
    
    var body: some View {
        Menu {
            Button(action: { exerciseType = "Strength Training" }) { Text("Strength Training") }
            Button(action: { exerciseType = "Sprints" }) { Text("Sprints") }
            Button(action: { exerciseType = "Distance Running" }) { Text("Distance Running") }
            Button(action: { exerciseType = "HIIT" }) { Text("HIIT") }
            Button(action: { exerciseType = "Biking" }) { Text("Biking") }
        } label: {
            HStack {
                Text(exerciseType.isEmpty ? "Select Exercise Type" : exerciseType)
                    .foregroundColor(exerciseType.isEmpty ? .gray : .black)
                Spacer()
                Image(systemName: "chevron.down")
                    .foregroundColor(.white)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 2))
        }
        .padding(.horizontal)
    }
}

struct ExerciseDetailView: View {
    @ObservedObject var exercise: Exercise
    var onDelete: () -> Void
    @State private var forceRefreshSets = UUID()

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text(exercise.exerciseType).bold()
                Spacer()
                Button(action: { }) {
                    Image(systemName: "camera")
                        .resizable()
                        .frame(width: 30, height: 25)
                        .foregroundColor(.black)
                }
            }
            .padding(.bottom, 10)
            
            ExerciseInputField(label: "Exercise Name", text: $exercise.exerciseName)
            
            SetListView(sets: $exercise.warmUpSets, label: "Warm-up Set", unit: "lb", repsUnit: "reps", onRemove: { index in
                exercise.warmUpSets.remove(at: index)
                forceRefreshSets = UUID()
            })
            
            SetListView(sets: $exercise.workingSets, label: "Working Set", unit: "lb", repsUnit: "reps", onRemove: { index in
                exercise.workingSets.remove(at: index)
                forceRefreshSets = UUID()
            })
            .id(forceRefreshSets)
            
            HStack {
                AddSetButton(title: "Add Warm-up Set", onAdd: {
                    exercise.warmUpSets.append(("", ""))
                    forceRefreshSets = UUID()
                })
                
                AddSetButton(title: "Add Working Set", onAdd: {
                    exercise.workingSets.append(("", ""))
                    forceRefreshSets = UUID()
                })
            }
            
            VStack(alignment: .leading, spacing: 15) {
                Text("Notes")
                TextEditor(text: $exercise.notes)
                    .frame(height: 50)
                    .padding(-5)
                    .background(Color.white)
                    .cornerRadius(5)
            }
            
            Button(action: { onDelete() }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
            .frame(maxWidth: .infinity, alignment: .bottomTrailing)
        }
        .padding()
        .background(.white)
        .cornerRadius(10)
        .padding(.horizontal, 1)
        .frame(maxWidth: .infinity)
    }
}

struct ExerciseInputField: View {
    var label: String
    @Binding var text: String
    
    var body: some View {
        TextField(label, text: $text)
            .frame(maxWidth: .infinity)
            .padding(5)
            .background(Color.white)
            .cornerRadius(5)
            .font(.title2)
            .bold()
    }
}

struct SetListView: View {
    @Binding var sets: [(String, String)]
    var label: String
    var unit: String
    var repsUnit: String
    var onRemove: (Int) -> Void
    
    var body: some View {
        ForEach(0..<sets.count, id: \.self) { index in
            HStack {
                Text("\(label) #\(index + 1)").font(.subheadline)
                Spacer()
                
                TextField("0", text: $sets[index].0)
                    .frame(width: 50)
                    .multilineTextAlignment(.trailing)
                Text(unit)
                
                Spacer()
                
                TextField("0", text: $sets[index].1)
                    .frame(width: 50)
                    .multilineTextAlignment(.trailing)
                Text(repsUnit)
                
                Button(action: { onRemove(index) }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
        }
    }
}

struct AddSetButton: View {
    var title: String
    var onAdd: () -> Void
    
    var body: some View {
        Button(action: { onAdd() }) {
            Text(title)
                .padding()
                .background(Color(red: 42/255, green: 42/255, blue: 42/255))
                .foregroundColor(.white)
                .cornerRadius(10)
                .font(.footnote)
        }
    }
}

struct AddExerciseButton: View {
    @Binding var curExerciseId: Int
    @Binding var exercises: [Int: Exercise]
    
    var body: some View {
        Button(action: {
            exercises[curExerciseId] = Exercise()
            curExerciseId += 1
        }) {
            Image(systemName: "plus.circle")
                .resizable()
                .frame(width: 50, height: 50)
        }
        .padding(.top, 20)
    }
}

struct PostButton: View {
    @Binding var templateName: String
    @Binding var exercises: [Int: Exercise]
    
    var body: some View {
        Button(action: {
            postTemplateToFirebase(templateName: templateName, exercises: exercises) { success in
                if success {
                    print("Template and exercises posted successfully.")
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


func postTemplateToFirebase(templateName: String, exercises: [Int: Exercise], completion: @escaping (Bool) -> Void) {
    guard let user = Auth.auth().currentUser else {
        print("User is not logged in.")
        completion(false)
        return
    }

    let db = Firestore.firestore()
    let userId = user.uid
    let currentDate = Date()

    // Template data with a timestamp
    let templateData: [String: Any] = [
        "templateName": templateName,
        "timestamp": Timestamp(date: currentDate),
        "userId": userId
    ]

    // Add template document to user's collection
    var templateRef: DocumentReference? = nil
    templateRef = db.collection("users").document(userId).collection("templates").addDocument(data: templateData) { error in
        if let error = error {
            print("Error adding template: \(error.localizedDescription)")
            completion(false)
            return
        }

        guard let templateId = templateRef?.documentID else {
            print("Template ID not found.")
            completion(false)
            return
        }

        // Add exercises to template
        for (_, exercise) in exercises {
            let exerciseData: [String: Any] = [
                "exerciseType": exercise.exerciseType,
                "exerciseName": exercise.exerciseName,
                "warmUpSets": exercise.warmUpSets.map { ["weight": $0.0, "reps": $0.1] },
                "workingSets": exercise.workingSets.map { ["weight": $0.0, "reps": $0.1] },
                "notes": exercise.notes,
                "timestamp": Timestamp(date: currentDate)
            ]
            
            db.collection("users").document(userId)
                .collection("templates").document(templateId)
                .collection("exercises").addDocument(data: exerciseData)
        }

        // Update workout history
        db.collection("users").document(userId).collection("workoutHistory").addDocument(data: templateData)
        
        // Update streak information
        updateStreak(userId: userId, currentDate: currentDate)

        completion(true)
    }
}

// Update streak information
func updateStreak(userId: String, currentDate: Date) {
    let db = Firestore.firestore()
    let userRef = db.collection("users").document(userId)
    
    userRef.getDocument { (document, error) in
        if let document = document, document.exists {
            let lastPostDate = document.data()?["lastPostDate"] as? Timestamp ?? Timestamp(date: Date(timeIntervalSince1970: 0))
            let currentStreak = document.data()?["currentStreak"] as? Int ?? 0
            let highestStreak = document.data()?["highestStreak"] as? Int ?? 0

            let calendar = Calendar.current
            let daysSinceLastPost = calendar.dateComponents([.day], from: lastPostDate.dateValue(), to: currentDate).day ?? 0
            
            var newStreak = daysSinceLastPost == 1 ? currentStreak + 1 : (daysSinceLastPost == 0 ? currentStreak : 1)
            let newHighestStreak = max(newStreak, highestStreak)

            userRef.updateData([
                "lastPostDate": Timestamp(date: currentDate),
                "currentStreak": newStreak,
                "highestStreak": newHighestStreak
            ])

            // Grant badge for specific streak milestones (e.g., 7 days)
            if newStreak == 7 {
                userRef.collection("badges").document("7DayStreak").setData([
                    "name": "7-Day Streak",
                    "dateAchieved": Timestamp(date: currentDate)
                ])
            }
        } else {
            print("User document does not exist")
        }
    }
}


#Preview {
    NewTemplateView()
}
