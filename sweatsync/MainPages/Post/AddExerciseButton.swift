//
//  AddExerciseButton.swift
//  sweatsync
//
//  Created by Ashwin on 11/11/24.
//

import Foundation
import SwiftUI

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
                .font(.custom(Theme.bodyFont, size: 18))
        }
        .padding(.top, 20)
    }
}
