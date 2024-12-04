//
//  Settings.swift
//  sweatsync
//
//  Created by Ashwin on 10/23/24.
//

import Foundation
import SwiftUI
import FirebaseFirestore

struct SettingsView: View {
    
    let user: User
    
    @State private var receiveNotifications = true
    @State private var turnOffComments = false
    
    @EnvironmentObject var session: SessionManager

    private let db = Firestore.firestore()
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Settings")
                    .font(.custom(Theme.bodyFont, size: 24))
                    .fontWeight(.bold)
                    .padding(.top, 40)
                    .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: 30) {
                    // Notification Preferences
                    HStack {
                        Text("Receive Notifications For New Likes and Comments On Posts")
                            .font(.custom(Theme.bodyFont, size: 16))
                            .foregroundColor(.white)
                        Spacer()
                        Toggle("", isOn: $receiveNotifications)
                            .labelsHidden()
                            .tint(Theme.primaryColor)
                            .onChange(of: receiveNotifications) { newValue in
                                toggleNotifications(userId: user.id, enabled: newValue)
                            }
                    }
                    
                    // Post Preferences
                    HStack {
                        Text("Disable Comments")
                            .font(.custom(Theme.bodyFont, size: 16))
                            .foregroundColor(.white)
                        Spacer()
                        Toggle("", isOn: $turnOffComments)
                            .labelsHidden()
                            .tint(Theme.primaryColor)
                            .onChange(of: turnOffComments) { newValue in
                                toggleComments(userId: user.id, disabled: newValue)
                            }
                    }
                    
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 20)
                
                Spacer()
                
                //Log Out Button
                Button(action: {
                    session.signOut()
                }) {
                    Text("Log Out")
                        .font(.custom(Theme.bodyFont, size: 16))
                        .foregroundColor(Theme.secondaryColor)
                        .frame(width: 150, height: 50)
                        .background(Theme.primaryColor)
                        .cornerRadius(10)
                }
                .padding(.bottom, 40)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.edgesIgnoringSafeArea(.all))
        }
        .onAppear {
            Task {
                receiveNotifications = await fetchNotificationsEnabled(userId: user.id)
                turnOffComments = await fetchCommentsDisabled(userId: user.id)
            }
        }
    }
}
    
//Firestore Functions

func toggleNotifications(userId: String, enabled: Bool) {
    let db = Firestore.firestore()
    db.collection("users").document(userId).updateData([
        "notificationsEnabled": enabled
    ]) { error in
        if let error = error {
            print("Error updating notificationsEnabled: \(error)")
        } else {
            print("Successfully updated notificationsEnabled to \(enabled)")
        }
    }
}

func toggleComments(userId: String, disabled: Bool) {
    let db = Firestore.firestore()
    db.collection("users").document(userId).updateData([
        "commentsDisabled": disabled
    ]) { error in
        if let error = error {
            print("Error updating commentsDisabled: \(error)")
        } else {
            print("Successfully updated commentsDisabled to \(disabled)")
        }
    }
}
