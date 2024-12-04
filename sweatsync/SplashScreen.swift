//
//  SplashScreen.swift
//  sweatsync
//
//  Created by aarushi chitagi on 10/10/24.
//

import Foundation
import SwiftUI

struct SplashScreen: View {
    @State private var active = true
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            if active {
                VStack(spacing: 20) {
                    Text("SWEATSYNC")
                        .font(.custom(Theme.bodyFont, size: 28))
                        .foregroundColor(Theme.primaryColor)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                MainScreen()
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    active = false
                }
            }
        }
    }
}

struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen()
    }
}

