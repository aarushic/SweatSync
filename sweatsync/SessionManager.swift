//
//  SessionManager.swift
//  sweatsync
//
//  Created by aarushi chitagi on 10/10/24.
//

import Foundation
import FirebaseAuth
import UserNotifications

final class SessionManager: ObservableObject {
    private let notificationDelegate = NotificationDelegate()
    private let isSignedInKey = "isSignedIn"
        
    enum CurrentState {
        case isSignedIn
        case notSignedIn
    }
    
    @Published private(set) var currentState: CurrentState?
    
    init() {
        configureCurrentState()
        // set notifications delegate
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.delegate = notificationDelegate
    }
    
    func configureCurrentState() {
        let isSignedIn = UserDefaults.standard.bool(forKey: isSignedInKey)
        currentState = isSignedIn ? .isSignedIn : .notSignedIn
    }
    
    func signIn() {
        currentState = .isSignedIn
        UserDefaults.standard.set(true, forKey: isSignedInKey)
        // Ask for notification permissions after signing in
        requestNotificationPermissions()
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut() 
            currentState = .notSignedIn
            UserDefaults.standard.set(false, forKey: isSignedInKey)
        } catch let signOutError as NSError {
            print("Error \(signOutError.localizedDescription)")
        }
    }
    
    private func requestNotificationPermissions() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting notification permissions: \(error)")
            } else if granted {
                print("Notifications permission granted")
            } else {
                print("Notifications permission denied")
            }
        }
    }
}
