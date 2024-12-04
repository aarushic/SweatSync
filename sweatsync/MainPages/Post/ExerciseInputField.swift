//
//  ExerciseInputField.swift
//  sweatsync
//
//  Created by Ashwin on 11/11/24.
//

import Foundation
import SwiftUI

struct ExerciseInputField: View {
    var label: String
    @Binding var text: String
    
    var body: some View {
        TextField(label, text: $text)
            .frame(maxWidth: .infinity)
            .padding(5)
            .background(Color.white)
            .cornerRadius(5)
            .font(.custom(Theme.bodyFont, size: 18))
            .bold()
            .onSubmit {
                dismissKeyboard()
            }
    }
}

