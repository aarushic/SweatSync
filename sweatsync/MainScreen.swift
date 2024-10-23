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
                case .isSignedIn:
                    TabBarView() 
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                case .notSignedIn:
                    LoginScreen()
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
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
