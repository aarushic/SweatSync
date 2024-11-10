import SwiftUI

struct Post: Identifiable {
    let id: String
    var userId: String
    var templateName: String
    var exercises: [Exercise]
    var likes: Int = 0
    var comments: [Comment] = []
    var userName: String
    var timestamp: Date
    
    struct Comment: Identifiable {
        let id: String
        let userId: String
        let userName: String
        let content: String
        let timestamp: Date
    }
}
