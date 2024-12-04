//
//  Notification.swift
//  sweatsync
//
//  Created by Ashwin on 11/30/24.
//

import Foundation

struct Notification: Identifiable {
    let id: String
    let type: String
    let fromUserId: String
    let fromUserName: String
    let fromUserProfilePictureUrl: String
    let postId: String
    let postTitle: String
    let content: String?
    let timestamp: Date
    var read: Bool
}
