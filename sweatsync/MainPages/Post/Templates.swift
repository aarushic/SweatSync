//
//  Templates.swift
//  sweatsync
//
//  Created by Ashwin on 11/9/24.
//
import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import PhotosUI
import FirebaseStorage

struct TemplatesView: View {
    @State private var templates: [Template] = []

    var body: some View {
        NavigationView {
            VStack {
                // Title
                Text("Choose Existing Template For Your Post")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.top, 20)
                
                // List of templates
                List(templates) { template in
                    NavigationLink(destination: ExistingTemplate(template: template)) {
                        Text(template.templateName)
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .listRowBackground(Theme.secondaryColor)
                }
                .scrollContentBackground(.hidden)
                .background(Color.black)
                .frame(height: 400)
                .cornerRadius(10)
                    
    
                
                Spacer()
                
                // "Create New Template" button
                NavigationLink(destination: NewTemplateView()) {
                    Text("Create new Template")
                        .font(.body)
                        .foregroundColor(.white)
                        .padding()
                        .background(Theme.secondaryColor)
                        .cornerRadius(10)
                }
                .padding(.bottom, 30)
            }
            .padding()
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Templates")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                fetchTemplates()
            }
        }
    }
    
    // Fetch templates from Firebase
    func fetchTemplates() {
        guard let user = Auth.auth().currentUser else {
            print("User is not logged in.")
            return
        }

        let db = Firestore.firestore()
        db.collection("users").document(user.uid).collection("templates").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching posts: \(error.localizedDescription)")
                return
            }

            templates.removeAll()

            snapshot?.documents.forEach { document in
                let data = document.data()
                let templateName = data["templateName"] as? String ?? "Untitled Template"
                let exercisesData = data["exercises"] as? [[String: Any]] ?? []

                var exercises: [Exercise] = exercisesData.compactMap { exerciseData in
                    let exerciseType = exerciseData["exerciseType"] as? String ?? ""
                    let exerciseName = exerciseData["exerciseName"] as? String ?? ""
                    let notes = exerciseData["notes"] as? String ?? ""
                    let warmUpSetsData = exerciseData["warmUpSets"] as? [[String: String]] ?? []
                    let workingSetsData = exerciseData["workingSets"] as? [[String: String]] ?? []

                    let warmUpSets = warmUpSetsData.compactMap { set in
                        (set["weight"] ?? "", set["reps"] ?? "")
                    }
                    let workingSets = workingSetsData.compactMap { set in
                        (set["weight"] ?? "", set["reps"] ?? "")
                    }

                    let exercise = Exercise()
                    exercise.exerciseType = exerciseType
                    exercise.exerciseName = exerciseName
                    exercise.warmUpSets = warmUpSets
                    exercise.workingSets = workingSets
                    exercise.notes = notes
                    
                    return exercise
                }

                let template = Template(templateName: templateName, exercises: exercises)
                templates.append(template)
            }
        }
    }


}

class Template: ObservableObject, Identifiable {
    var id = UUID()
    @Published var templateName: String
    @Published var exercises: [Exercise]

    init(templateName: String, exercises: [Exercise]) {
        self.templateName = templateName
        self.exercises = exercises
    }
}

// Create a new template view (navigates here when the button is tapped)
struct CreateTemplateView: View {
    var body: some View {
        VStack {
            Text("Create a New Template")
                .font(.largeTitle)
                .padding()
            Spacer()
        }
        .navigationTitle("New Template")
    }
}

struct TemplateSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        TemplatesView()
    }
}
