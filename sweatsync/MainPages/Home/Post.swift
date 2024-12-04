//
//  Post.swift
//  sweatsync
//
//  Created by Ashwin on 11/13/24.
//

import Foundation
import SwiftUI

struct Post: Identifiable {
    let id: String
    var userId: String
    var templateName: String
    var templateImageUrl: String
    var exercises: [Exercise]
    var likes: Set<String> = []
    var comments: [Comment] = []
    var userName: String
    var timestamp: Date
    var taggedUser: String?

    struct Comment: Identifiable {
        let id: String
        let userId: String
        let userName: String
        let commenterId: String
        let content: String
        let timestamp: Date
    }
}
