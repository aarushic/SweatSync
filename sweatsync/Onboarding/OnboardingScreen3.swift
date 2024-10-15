//
//  OnboardingScreen3.swift
//  sweatsync
//
//  Created by aarushi chitagi on 10/14/24.
//

import Foundation
import SwiftUI

struct OnboardingScreen3: View {
    let action: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            //green box
            RoundedRectangle(cornerRadius: 20)
                .fill(Theme.primaryColor)
                .frame(height: 400)
                .overlay(
                    VStack(spacing: 20) {
                        //icon
                        Image(systemName: "clipboard.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .foregroundColor(Theme.secondaryColor)
                        
                        //test
                        Text("information about the app")
                            .foregroundColor(.black)
                            .font(.headline)
                        
                        //next
                        Button(action: {
                            action()
                        }) {
                            Text("Next")
                                .frame(width: 170, height: 50)
                                .background(Theme.secondaryColor)
                                .foregroundColor(.white)
                                .cornerRadius(25)
                        }
                    }
                )
                .padding(.horizontal, 40)
            Spacer()
        }
        .background(Color.black)
        .edgesIgnoringSafeArea(.all)
    }
}

