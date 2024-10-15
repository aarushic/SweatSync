//
//  sweatsyncApp.swift
//  sweatsync
//
//  Created by aarushi chitagi on 10/10/24.
//

import SwiftUI
import FirebaseCore


class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct sweatsyncApp: App {
    @StateObject private var session = SessionManager()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            SplashScreen()
                .environmentObject(session)
        }
    }
}


