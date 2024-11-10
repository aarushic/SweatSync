//
//  PostButton.swift
//  sweatsync
//
//  Created by Ashwin on 11/9/24.
//

import SwiftUI
import Foundation

struct PostButton: View {
    @Binding var templateName: String
    @Binding var exercises: [Int: Exercise]
    @Binding var isShowingHomeScreen: Bool
    @Binding var saveAsTemplate: Bool
    
    var body: some View {
        Button("Post") {
            postTemplateToFirebase(templateName: templateName, exercises: exercises, saveAsTemplate: saveAsTemplate) { success in
                if success {
                    isShowingHomeScreen = true
                } else {
                    print("Failed to post template.")
                }
            }
        }
        .padding()
        .background(Color.blue)
        .cornerRadius(10)
        .foregroundColor(.white)
        .font(.title3)
    }
}
