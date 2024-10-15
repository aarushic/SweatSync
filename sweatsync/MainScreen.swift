//
//  MainScreen.swift
//  sweatsync
//
//  Created by aarushi chitagi on 10/10/24.
//

import Foundation
import SwiftUI

struct MainScreen: View {
    @EnvironmentObject var session: SessionManager
    
    var body: some View {
        ZStack {
            switch session.currentState {
                case .onboarding1:
                    OnboardingScreen1(action: session.completeOnboarding1)
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                case .onboarding2:
                    OnboardingScreen2(action: session.completeOnboarding2)
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                case .onboarding3:
                    OnboardingScreen3(action: session.completeOnboarding3)
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                case .dashboard:
                    LoginScreen()
                default:
                    EmptyView()
            }
        }
        .background(Color.black.ignoresSafeArea())
        .animation(.easeInOut, value: session.currentState)
        .onAppear {
            session.configureCurrentState()
        }
    }
}
