//
//  TabBarView.swift
//  sweatsync
//
//  Created by aarushi chitagi on 10/14/24.
//

import Foundation
import SwiftUI

struct TabBarView: View {
    var body: some View {
        // Tab Bar
        HStack {
            Button(action: {
                // Home action
            }) {
                VStack {
                    Image(systemName: "house.fill")
                        .foregroundColor(Color(red: 208/255, green: 247/255, blue: 147/255))
                    Text("")
                }
            }
            Spacer()

            Button(action: {
                // Logs action
            }) {
                VStack {
                    Image(systemName: "list.bullet")
                        .foregroundColor(.gray)
                    Text("")
                }
            }
            Spacer()

            Button(action: {
                // Add action
            }) {
                VStack {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.gray)
                    Text("")
                }
            }
            Spacer()

            Button(action: {
                // Notifications action
            }) {
                VStack {
                    Image(systemName: "bell.fill")
                        .foregroundColor(.gray)
                    Text("")
                }
            }
            Spacer()

            Button(action: {
                // Profile action
            }) {
                VStack {
                    Image(systemName: "person.fill")
                        .foregroundColor(.gray)
                    Text("")
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 10)
        .background(Color.black)
    }
    
}
