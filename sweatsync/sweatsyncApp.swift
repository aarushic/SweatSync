//
//  sweatsyncApp.swift
//  sweatsync
//
//  Created by aarushi chitagi on 10/10/24.
//

import SwiftUI

@main
struct sweatsyncApp: App {
    @StateObject private var session = SessionManager()
        
    var body: some Scene {
        WindowGroup {
            SplashScreen()
                .environmentObject(session)
        }
    }
}


