import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import PhotosUI
import FirebaseFirestore
import FirebaseStorage

struct ExerciseDetailView: View {
    @ObservedObject var exercise: Exercise
    var onDelete: () -> Void
    @State private var showImagePicker: Bool = false
    @State private var photo: PhotosPickerItem?
    @State private var forceRefreshSets = UUID()

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text(exercise.exerciseType).bold()
                Spacer()
                Button(action: { showImagePicker = true }) {
                    Image(systemName: "camera")
                        .resizable()
                        .frame(width: 30, height: 25)
                        .foregroundColor(.black)
                }
            }
            .padding(.bottom, 10)
            
            // Display selected image if available
            if let selectedImageData = exercise.selectedImageData,
               let image = UIImage(data: selectedImageData) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }

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
        .photosPicker(isPresented: $showImagePicker, selection: $photo, matching: .images)
        .onChange(of: photo) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    exercise.selectedImageData = data  // Temporarily store selected image data
                }
            }
        }
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
