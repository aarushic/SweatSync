//
//  SwimmingDetailView.swift
//  sweatsync
//
//  Created by aarushi chitagi on 12/9/24.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import PhotosUI
import FirebaseFirestore
import FirebaseStorage

struct SwimmingDetailView: View {
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

            ExerciseInputField(label: "Swim Name", text: $exercise.exerciseName)
                .font(.custom(Theme.bodyFont, size: 16))

            VStack(alignment: .leading) {
                Text("Stroke Type")
                    .font(.custom(Theme.bodyFont, size: 14))

                TextField("Enter stroke type", text: Binding(
                    get: { exercise.strokeType ?? "" },
                    set: { exercise.strokeType = $0 }
                ))
                .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            //laps, distance, and duration
            HStack(spacing: 20) {
                VStack(alignment: .leading) {
                    Text("Laps")
                        .font(.custom(Theme.bodyFont, size: 14))

                    TextField("Enter laps", text: Binding(
                        get: { exercise.laps ?? "" },
                        set: { exercise.laps = $0 }
                    ))
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                }

                VStack(alignment: .leading) {
                    Text("Distance (m)")
                        .font(.custom(Theme.bodyFont, size: 14))

                    TextField("Enter distance", text: Binding(
                        get: { exercise.swimDistance ?? "" },
                        set: { exercise.swimDistance = $0 }
                    ))
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                }

                VStack(alignment: .leading) {
                    Text("Duration (s)")
                        .font(.custom(Theme.bodyFont, size: 14))

                    TextField("Enter duration", text: Binding(
                        get: { exercise.swimDuration ?? "" },
                        set: { exercise.swimDuration = $0 }
                    ))
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }

            //notes Section
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

            //delete
            Button(action: { onDelete() }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
            .frame(maxWidth: .infinity, alignment: .bottomTrailing)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .padding(.horizontal, 1)
        .frame(maxWidth: .infinity)
    }
}
