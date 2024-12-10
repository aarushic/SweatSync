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
    //strength exercise
    @Published var warmUpSets: [(String, String)]
    @Published var workingSets: [(String, String)]
    //sprint exercise
    @Published var distance: String
    @Published var time: String
    @Published var notes: String
    //biking exercise
    @Published var bikeDistance: String
    @Published var bikeDuration: String
    @Published var averageSpeed: String
    @Published var elevationGain: String
    //swimming exercise
    @Published var strokeType: String
    @Published var laps: String
    @Published var swimDistance: String
    @Published var swimDuration: String
    
    public let id: UUID

    init() {
        self.exerciseType = ""
        self.exerciseName = ""
        self.warmUpSets = [("", "")]
        self.workingSets = [("", "")]
        self.notes = ""
        self.id = UUID()
        self.distance = ""
        self.time = ""
        self.bikeDistance = ""
        self.bikeDuration = ""
        self.averageSpeed = ""
        self.elevationGain = ""
        self.strokeType = ""
        self.laps = ""
        self.swimDistance = ""
        self.swimDuration = ""
    }
}
