//
//  SprintDetailView.swift
//  sweatsync
//
//  Created by Ashwin on 11/13/24.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import PhotosUI
import FirebaseFirestore
import FirebaseStorage

struct SprintDetailView: View {
    @ObservedObject var exercise: Exercise
    var onDelete: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text(exercise.exerciseType)
                    .font(.custom(Theme.bodyFont, size: 18))
                    .bold()
                Spacer()
            }
            .padding(.bottom, 10)

            ExerciseInputField(label: "Sprint Name", text: $exercise.exerciseName)
                .font(.custom(Theme.bodyFont, size: 16))
            
            //distance and Time inputs for sprint training
            HStack {
                VStack(alignment: .leading) {
                    Text("Distance (m)")
                        .font(.custom(Theme.bodyFont, size: 14))
                    
                    TextField("Enter distance", text: Binding(
                        get: { exercise.distance ?? "" },
                        set: { exercise.distance = $0 }
                    ))
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onSubmit {
                        dismissKeyboard()
                    }
                }
                
                VStack(alignment: .leading) {
                    Text("Time (s)")
                        .font(.custom(Theme.bodyFont, size: 14))
                    TextField("Enter time", text: Binding(
                        get: { exercise.time ?? "" },
                        set: { exercise.time = $0 }
                    ))
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onSubmit {
                        dismissKeyboard()
                    }
                }
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

