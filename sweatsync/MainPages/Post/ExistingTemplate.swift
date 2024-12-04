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
    @State private var showImagePicker: Bool = false
    @State private var decodedImage: UIImage?
    @State private var templateImageUrl: String?
    @State private var saveAsTemplate: Bool = false
    @State private var isShowingHomeScreen: Bool = false
    @State private var errorMessage: String?
    @State private var taggedUser: String = ""

    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                headerView
                
                TextField("Tag someone (email)", text: $taggedUser)
                    .frame(maxWidth: .infinity)
                    .padding(5)
                    .background(Color.white)
                    .cornerRadius(5)
                    .font(.custom(Theme.bodyFont, size: 15))
                    .textInputAutocapitalization(.never)
                    .bold()
                    .onSubmit {
                        dismissKeyboard()
                    }
                
                if let image = decodedImage {
                    HStack {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 10)
                }
            
                
                ForEach(template.exercises) { exercise in
                    exerciseView(for: exercise)
                        .font(.custom(Theme.bodyFont, size: 16))
                }
                
                Spacer()
                
                // Error message display
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.top, 10)
                }
                
                Spacer()
                
                Button(action: {
                    // Validate inputs
                    if template.templateName.isEmpty {
                        errorMessage = "Please enter a post name."
                    } else if decodedImage == nil || (templateImageUrl?.isEmpty ?? true) {
                        errorMessage = "Please select an image."
                    } else {
                        //clear error and attempt to post
                        errorMessage = nil
                        postTemplateWithImage()
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
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
        }
        .photosPicker(isPresented: $showImagePicker, selection: $selectedTemplatePhoto, matching: .images)
        .onChange(of: selectedTemplatePhoto) { newItem in
            Task {
                if let newItem = newItem {
                    if let data = try? await newItem.loadTransferable(type: Data.self) {
                        decodedImage = UIImage(data: data)
                        templateImageUrl = decodedImage?.jpegData(compressionQuality: 0.5)?.base64EncodedString() ?? ""
                    }
                }
            }
        }
        .background(Color.black.ignoresSafeArea())
        .fullScreenCover(isPresented: $isShowingHomeScreen) {
            TabBarView()
        }
        .onTapGesture {
            dismissKeyboard()
        }
    }
    
    var headerView: some View {
        HStack {
            Text(template.templateName)
                .font(.custom(Theme.headingFont, size: 24))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 5)
            Spacer()
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
    }

    private func exerciseView(for exercise: Exercise) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(exercise.exerciseName)
                .font(.custom(Theme.bodyFont, size: 20))
                .bold()
                .padding(.vertical, 5)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if exercise.exerciseType == "Sprints" {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Sprint Details").font(.custom(Theme.bodyFont, size: 20))
                    
                    Text("Distance: \(exercise.distance) meters")
                        .font(.custom(Theme.bodyFont, size: 16))
                        .foregroundColor(Theme.secondaryColor)
                
                    Text("Time: \(exercise.time) seconds")
                        .font(.custom(Theme.bodyFont, size: 16))
                        .foregroundColor(Theme.secondaryColor)
                }
                .padding(.vertical, 5)
            }
            else {
                setsView(title: "Warm-up Sets", sets: exercise.warmUpSets)
                setsView(title: "Working Sets", sets: exercise.workingSets)
            }
            
            notesView(for: exercise)
        }
    }
    
    private func setsView(title: String, sets: [(String, String)]) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title).font(.custom(Theme.bodyFont, size: 20))
            ForEach(0..<sets.count, id: \.self) { index in
                Text("Set \(index + 1): Weight \(sets[index].0) lbs, Reps \(sets[index].1)")
                    .font(.custom(Theme.bodyFont, size: 16))
                    .foregroundColor(Theme.secondaryColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.vertical, 5)
    }

    private func notesView(for exercise: Exercise) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Notes").font(.custom(Theme.bodyFont, size: 20))

            TextEditor(text: bindingForExerciseNotes(exercise))
                .frame(height: 50)
                .background(Color.white)
                .cornerRadius(5)
                .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray, lineWidth: 1))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 5)
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

    //Helper Functions
    private func showTemplateImagePicker() {
        selectedTemplatePhoto = nil
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
            "exercises": exercisesData,
            "taggedUser": taggedUser
        ]
        
        if let imageUrl = templateImageUrl {
            postData["templateImageUrl"] = imageUrl
        }

        updateStreak(user)

        db.collection("users").document(userId).collection("posts").addDocument(data: postData) { error in
            if let error = error {
                print("Error posting template with image: \(error.localizedDescription)")
            } else {
                print("Template posted successfully.")
                isShowingHomeScreen = true
                updateLastPostDate(user)

                // Increment workout count and check achievements
                db.collection("users").document(userId).setData([
                    "workoutCount": FieldValue.increment(Int64(1))
                ], merge: true) { error in
                    if let error = error {
                        print("Error updating workout count: \(error.localizedDescription)")
                    } else {
                        checkAndUpdateAchievements(for: user)
                    }
                }
            }
        }
    }


    private func createExerciseData(_ exercise: Exercise) -> [String: Any] {
        return [
            "exerciseType": exercise.exerciseType,
            "exerciseName": exercise.exerciseName,
            "warmUpSets": exercise.warmUpSets.map { ["weight": $0.0, "reps": $0.1] },
            "workingSets": exercise.workingSets.map { ["weight": $0.0, "reps": $0.1] },
            "notes": exercise.notes,
            "timestamp": Timestamp(date: Date()),
        ]
    }
}
