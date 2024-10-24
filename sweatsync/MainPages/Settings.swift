//
//  Settings.swift
//  sweatsync
//
//  Created by Ashwin on 10/23/24.
//

import Foundation
import SwiftUI

struct SettingsView: View {
    @State private var receiveNotifications = true
    @State private var turnOffComments = false
    
    @EnvironmentObject var session: SessionManager

    var body: some View {
        NavigationStack {
            VStack {
                Text("Settings")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top, 40)
                    .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: 30) {
                    //Notification Preferences
                    HStack {
                        Text("Receive Notifications For New Likes Or Comments On Posts")
                            .font(.system(size: 16))
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                        Spacer()
                        Toggle("", isOn: $receiveNotifications)
                            .labelsHidden()
                            .tint(Theme.primaryColor)
                    }
                    
                    //Post Preferences
                    HStack {
                        Text("Turn Off Comments On Posts")
                            .font(.system(size: 16))
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                        Spacer()
                        Toggle("", isOn: $turnOffComments)
                            .labelsHidden()
                            .tint(Theme.primaryColor)
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
                        .font(.system(size: 16))
                        .fontWeight(.medium)
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
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
