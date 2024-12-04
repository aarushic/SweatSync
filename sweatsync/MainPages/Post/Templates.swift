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
                Text("Choose Existing Template For Your Post")
                    .font(.custom(Theme.bodyFont, size: 20))
                    .foregroundColor(.white)
                    .padding(.top, 20)
                    .multilineTextAlignment(.center)
                
                List(templates) { template in
                    NavigationLink(destination: ExistingTemplate(template: template)) {
                        HStack {
                            Text(template.templateName)
                                .font(.custom(Theme.bodyFont, size: 18))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Theme.primaryColor)
                        }
                        .padding()
                        .background(Theme.secondaryColor)
                        .cornerRadius(8)
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
                .scrollContentBackground(.hidden)
                .background(Color.black)
                .frame(height: 400)
                .cornerRadius(12)
                .padding(.horizontal)
                .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 3)
                .listStyle(PlainListStyle())
                
                Spacer()
                
                NavigationLink(destination: NewTemplateView()) {
                    Text("Create New Post")
                        .font(.custom(Theme.bodyFont, size: 18))
                        .foregroundColor(Theme.secondaryColor)
                        .padding()
                        .background(Theme.primaryColor)
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
                    let exercise = Exercise()

                    exercise.exerciseType = exerciseData["exerciseType"] as? String ?? ""
                    exercise.exerciseName = exerciseData["exerciseName"] as? String ?? ""
                    exercise.notes  = exerciseData["notes"] as? String ?? ""
                  
                    if exercise.exerciseType == "Sprints" {
                        exercise.distance = exerciseData["distance"] as? String ?? ""
                        exercise.time = exerciseData["time"] as? String ?? ""
                    } else {
                        let warmUpSetsData = exerciseData["warmUpSets"] as? [[String: String]] ?? []
                        let workingSetsData = exerciseData["workingSets"] as? [[String: String]] ?? []

                        let warmUpSets = warmUpSetsData.compactMap { set in
                            (set["weight"] ?? "", set["reps"] ?? "")
                        }
                        let workingSets = workingSetsData.compactMap { set in
                            (set["weight"] ?? "", set["reps"] ?? "")
                        }
                        
                        exercise.warmUpSets = warmUpSets
                        exercise.workingSets = workingSets
                    }

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
