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
        TabView{
            Group{
                HomeScreenView()
                    .tabItem {
                        Image(systemName: "house.fill")
                    }
                
                // Replace with Calendar view
//                HomeScreenView()
//                    .tabItem {
//                        Image(systemName: "calendar")
//                    }
                
                // Replace with post view
                TemplatesView()
                    .tabItem {
                        Image(systemName: "plus.circle.fill")
                    }
                
                // Replace with Notification view
                HomeScreenView()
                    .tabItem {
                        Image(systemName: "bell.fill")
                    }
                    // badge for notifications
                    .badge(2)
                
                // Replace with profile view
                ProfileScreen()
                    .tabItem {
                        Image(systemName: "person.fill")
                    }
            }
            .toolbarBackground(Color(red: 42/255, green: 42/255, blue: 42/255), for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
        }
    }
    
}

struct TabBarViewPreview: PreviewProvider {
    static var previews: some View {
        TabBarView()
    }
}
