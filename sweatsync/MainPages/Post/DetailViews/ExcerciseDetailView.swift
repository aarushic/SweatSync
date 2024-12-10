import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import PhotosUI
import FirebaseFirestore
import FirebaseStorage

struct ExerciseDetailView: View {
    @ObservedObject var exercise: Exercise
    var onDelete: () -> Void
    @State private var forceRefreshSets = UUID()

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text(exercise.exerciseType)
                    .font(.custom(Theme.bodyFont, size: 18))
                    .bold()
                Spacer()
            }
            .padding(.bottom, 10)
            
            ExerciseInputField(label: "Exercise Name", text: $exercise.exerciseName)
                .font(.custom(Theme.bodyFont, size: 16))
            
            SetListView(sets: $exercise.warmUpSets, label: "Warm-up Set", unit: "lb", repsUnit: "reps", onRemove: { index in
                exercise.warmUpSets.remove(at: index)
                forceRefreshSets = UUID()
            })
            .font(.custom(Theme.bodyFont, size: 14))
            
            SetListView(sets: $exercise.workingSets, label: "Working Set", unit: "lb", repsUnit: "reps", onRemove: { index in
                exercise.workingSets.remove(at: index)
                forceRefreshSets = UUID()
            })
            .font(.custom(Theme.bodyFont, size: 14))
            .id(forceRefreshSets)
            
            HStack {
                AddSetButton(title: "Add Warm-up Set", onAdd: {
                    exercise.warmUpSets.append(("", ""))
                    forceRefreshSets = UUID()
                })
                .font(.custom(Theme.bodyFont, size: 14))
                
                AddSetButton(title: "Add Working Set", onAdd: {
                    exercise.workingSets.append(("", ""))
                    forceRefreshSets = UUID()
                })
                .font(.custom(Theme.bodyFont, size: 14))
            }
            
            VStack(alignment: .leading, spacing: 15) {
                Text("Notes")
                    .font(.custom(Theme.bodyFont, size: 16))
                TextEditor(text: $exercise.notes)
                    .frame(height: 50)
                    .padding(-5)
                    .background(Color.white)
                    .cornerRadius(5)
                    .font(.custom(Theme.bodyFont, size: 14))
                    .onSubmit {
                        dismissKeyboard()
                    }
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

