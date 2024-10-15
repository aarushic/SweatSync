//
//  SessionManager.swift
//  sweatsync
//
//  Created by aarushi chitagi on 10/10/24.
//

import Foundation

final class SessionManager: ObservableObject {
    
    private let hasSeenOnboarding1 = "hasSeenOnboarding1"
    private let hasSeenOnboarding2 = "hasSeenOnboarding2"
    private let hasSeenOnboarding3 = "hasSeenOnboarding3"
    
    enum CurrentState {
        case onboarding1
        case onboarding2
        case onboarding3
        case dashboard
    }
    
    @Published private(set) var currentState: CurrentState?
    
    func configureCurrentState() {
        let hasCompletedOnboarding1 = UserDefaults.standard.bool(forKey: hasSeenOnboarding1)
        let hasCompletedOnboarding2 = UserDefaults.standard.bool(forKey: hasSeenOnboarding2)
        let hasCompletedOnboarding3 = UserDefaults.standard.bool(forKey: hasSeenOnboarding3)
        currentState = hasCompletedOnboarding1 && hasCompletedOnboarding2 && hasCompletedOnboarding3 ? .dashboard : .onboarding1
    }
    
    
    func completeOnboarding1() {
        currentState = .onboarding2
        UserDefaults.standard.set(true, forKey: hasSeenOnboarding1)
    }
    
    func completeOnboarding2() {
        currentState = .onboarding3
        UserDefaults.standard.set(true, forKey: hasSeenOnboarding2)
    }
    
    func completeOnboarding3() {
        currentState = .dashboard
        UserDefaults.standard.set(true, forKey: hasSeenOnboarding3)
    }
    
  
}
