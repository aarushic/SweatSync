//
//  Exercise.swift
//  sweatsync
//
//  Created by Ashwin on 10/23/24.
//

import Foundation

public class Exercise: ObservableObject, Identifiable {
    var exerciseType:String
    var exerciseName:String
    var warmUpSets:[(String, String)]
    var workingSets:[(String, String)]
    var notes:String
    
    init() {
        self.exerciseType = ""
        self.exerciseName = ""
        self.warmUpSets = [("", "")]
        self.workingSets = [("", "")]
        self.notes = ""
    }
}
