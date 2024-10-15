//
//  SplashScreen.swift
//  sweatsync
//
//  Created by aarushi chitagi on 10/10/24.
//

import Foundation
import SwiftUI

struct SplashScreen: View {
    @State var active = true
    
    var body: some View {
        ZStack {
            if active {
                VStack {
                    Text("SweatSync")
                        .multilineTextAlignment(.center)
                        .font(.largeTitle)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                MainScreen()
            }
        }.onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation{
                    active = false
                }
            }
        }
    }
}

