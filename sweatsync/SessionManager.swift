//
//  SessionManager.swift
//  sweatsync
//
//  Created by aarushi chitagi on 10/10/24.
//

import Foundation

final class SessionManager: ObservableObject {
    
    private let isSignedInKey = "isSignedIn"
        
    enum CurrentState {
        case isSignedIn
        case notSignedIn
    }
    
    @Published private(set) var currentState: CurrentState?
    
    init() {
        configureCurrentState()
    }
    
    func configureCurrentState() {
        let isSignedIn = UserDefaults.standard.bool(forKey: isSignedInKey)
        currentState = isSignedIn ? .isSignedIn : .notSignedIn
    }
    
    func signIn() {
        currentState = .isSignedIn
        UserDefaults.standard.set(true, forKey: isSignedInKey)
    }
    
    func signOut() {
        currentState = .notSignedIn
        UserDefaults.standard.set(false, forKey: isSignedInKey)
    }
}
