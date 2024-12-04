//
//  NotificationDelegate.swift
//  sweatsync
//
//  Created by Ashwin on 11/30/24.
//

import Foundation
import UserNotifications

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    // Handle notifications when the app is in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show banner
        completionHandler([.banner])
    }

    // Handle actions when the user interacts with a notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Perform any action when the user taps the notification
        print("User interacted with notification: \(response.notification.request.content.title)")
        completionHandler()
    }
}
