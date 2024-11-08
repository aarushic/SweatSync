//
//  Exercise.swift
//  sweatsync
//
//  Created by Ashwin on 10/23/24.
//

import Foundation

public class Exercise: ObservableObject, Identifiable {
    @Published var exerciseType: String
    @Published var exerciseName: String
    @Published var warmUpSets: [(String, String)]
    @Published var workingSets: [(String, String)]
    @Published var notes: String
    @Published var imageUrl: String?  // URL to the uploaded image in Firebase
    @Published var selectedImageData: Data?  // Temporarily store selected image data before upload

    public let id: UUID  // Unique identifier to conform to Identifiable

    init() {
        self.exerciseType = ""
        self.exerciseName = ""
        self.warmUpSets = [("", "")]
        self.workingSets = [("", "")]
        self.notes = ""
        self.imageUrl = nil
        self.selectedImageData = nil
        self.id = UUID()
    }
}
