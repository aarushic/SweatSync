//
//  ExistingTemplate.swift
//  sweatsync
//
//  Created by Ashwin on 11/9/24.
//
import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import PhotosUI
import FirebaseStorage

struct ExistingTemplate: View {
    @ObservedObject var template: Template
    @State private var selectedTemplatePhoto: PhotosPickerItem? = nil
    @State private var selectedTemplateImageData: Data? = nil

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    templateHeader
                    Spacer()
                    Button(action: { showTemplateImagePicker() }) {
                        Image(systemName: "camera")
                            .resizable()
                            .frame(width: 30, height: 25)
                            .foregroundColor(.black)
                    }
                }
                
                ForEach(template.exercises) { exercise in
                    exerciseView(for: exercise)
                }
                Spacer()
                postButton
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
        }
        .photosPicker(
            isPresented: Binding(
                get: { selectedTemplatePhoto != nil },
                set: { if !$0 { selectedTemplatePhoto = nil } }
            ),
            selection: $selectedTemplatePhoto,
            matching: .images
        )
        .onChange(of: selectedTemplatePhoto) { newItem in
            handleTemplatePhotoChange(newItem)
        }
        .background(Color.black.ignoresSafeArea())
    }

    //Helper Views
    private var templateHeader: some View {
        Text(template.templateName)
            .font(.custom("LeagueSpartan-Medium", size: 24))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 5)
    }

    private func setsView(title: String, sets: [(String, String)]) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title).font(.headline)
            ForEach(0..<sets.count, id: \.self) { index in
                Text("Set \(index + 1): Weight \(sets[index].0) lbs, Reps \(sets[index].1)")
                    .foregroundColor(Theme.secondaryColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.vertical, 5)
    }

    private func notesView(for exercise: Exercise) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Notes").font(.headline)
            TextEditor(text: bindingForExerciseNotes(exercise))
                .frame(height: 50)
                .background(Color.white)
                .cornerRadius(5)
                .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray, lineWidth: 1))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 5)
    }
    
    private func exerciseView(for exercise: Exercise) -> some View {
        VStack {
            Text(exercise.exerciseName)
                .font(.custom("LeagueSpartan-Medium", size: 20))
                .bold()
                .padding(.vertical, 5)
                .frame(maxWidth: .infinity, alignment: .leading)
            setsView(title: "Warm-up Sets", sets: exercise.warmUpSets)
            setsView(title: "Working Sets", sets: exercise.workingSets)
            notesView(for: exercise)
        }
    }

    private func bindingForExerciseNotes(_ exercise: Exercise) -> Binding<String> {
        Binding<String>(
            get: {
                exercise.notes
            },
            set: { newValue in
                if let index = template.exercises.firstIndex(where: { $0.id == exercise.id }) {
                    template.exercises[index].notes = newValue
                }
            }
        )
    }

    private var postButton: some View {
        Button("Post") {
            postTemplateWithImage()
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Theme.secondaryColor)
        .foregroundColor(Theme.primaryColor)
        .cornerRadius(10)
        .padding(.top, 10)
    }

    //Helper Functions
    private func showTemplateImagePicker() {
        selectedTemplatePhoto = nil
    }

    private func handleTemplatePhotoChange(_ newItem: PhotosPickerItem?) {
        Task {
            if let data = try? await newItem?.loadTransferable(type: Data.self) {
                selectedTemplateImageData = data
            }
        }
    }

    private func postTemplateWithImage() {
        guard let user = Auth.auth().currentUser else {
            print("User is not logged in.")
            return
        }

        let db = Firestore.firestore()
        let userId = user.uid
        let currentDate = Date()
        let exercisesData = template.exercises.map(createExerciseData)

        var postData: [String: Any] = [
            "templateName": template.templateName,
            "timestamp": Timestamp(date: currentDate),
            "exercises": exercisesData
        ]

        if let imageData = selectedTemplateImageData {
            postData["templateImageBase64"] = imageData.base64EncodedString()
        }

        updateStreak(user)
        
        db.collection("users").document(userId).collection("posts").addDocument(data: postData) { error in
            if let error = error {
                print("Error posting template with image: \(error.localizedDescription)")
            } else {
                print("Template posted successfully.")
                updateLastPostDate(user)
            }
        }
    }

    private func createExerciseData(_ exercise: Exercise) -> [String: Any] {
        return [
            "exerciseType": exercise.exerciseType,
            "exerciseName": exercise.exerciseName,
            "warmUpSets": exercise.warmUpSets.map { ["weight": $0.0, "reps": $0.1] },
            "workingSets": exercise.workingSets.map { ["weight": $0.0, "reps": $0.1] },
            "notes": exercise.notes
        ]
    }
}
