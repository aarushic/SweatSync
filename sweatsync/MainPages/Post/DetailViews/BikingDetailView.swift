//
//  BikingDetailView.swift
//  sweatsync
//
//  Created by aarushi chitagi on 12/9/24.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import PhotosUI
import FirebaseStorage

struct BikingDetailView: View {
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

            ExerciseInputField(label: "Ride Name", text: $exercise.exerciseName)
                .font(.custom(Theme.bodyFont, size: 16))

            //distance and duration
            HStack(spacing: 20) {
                VStack(alignment: .leading) {
                    Text("Distance (km)")
                        .font(.custom(Theme.bodyFont, size: 14))

                    TextField("Enter distance", text: Binding(
                        get: { exercise.bikeDistance ?? "" },
                        set: { exercise.bikeDistance = $0 }
                    ))
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                }

                VStack(alignment: .leading) {
                    Text("Duration (min)")
                        .font(.custom(Theme.bodyFont, size: 14))

                    TextField("Enter duration", text: Binding(
                        get: { exercise.bikeDuration ?? "" },
                        set: { exercise.bikeDuration = $0 }
                    ))
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }

            //average Speed and elevation gain
            HStack(spacing: 20) {
                VStack(alignment: .leading) {
                    Text("Avg. Speed (km/h)")
                        .font(.custom(Theme.bodyFont, size: 14))

                    TextField("Enter speed", text: Binding(
                        get: { exercise.averageSpeed ?? "" },
                        set: { exercise.averageSpeed = $0 }
                    ))
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                }

                VStack(alignment: .leading) {
                    Text("Elevation Gain (m)")
                        .font(.custom(Theme.bodyFont, size: 14))

                    TextField("Enter elevation gain", text: Binding(
                        get: { exercise.elevationGain ?? "" },
                        set: { exercise.elevationGain = $0 }
                    ))
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }

            //notes
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
