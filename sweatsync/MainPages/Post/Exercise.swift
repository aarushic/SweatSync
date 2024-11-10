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
    @Published var imageUrl: String?
    @Published var selectedImageData: Data?

    public let id: UUID  

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
