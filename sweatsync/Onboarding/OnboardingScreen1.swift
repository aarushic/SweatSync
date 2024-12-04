//
//  OnboardingScreen1.swift
//  sweatsync
//
//  Created by aarushi chitagi on 10/14/24.
//

import Foundation
import SwiftUI

struct OnboardingScreen1: View {
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                //green box
                RoundedRectangle(cornerRadius: 20)
                    .fill(Theme.primaryColor)
                    .frame(height: 530)
                    .overlay(
                        VStack(spacing: 20) {
                            //icon
                            Image(systemName: "figure.run")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                                .foregroundColor(Theme.secondaryColor)
                            
                            //text
                            Text("Track and Share Your Journey")
                                .foregroundColor(.black)
                                .font(.custom(Theme.headingFont, size: 26))
                                .multilineTextAlignment(.center)
                            
                            VStack(spacing: 30){
                                Text("SweatSync combines fitness tracking with social networking to keep you motivated and accountable.")
                                    .foregroundColor(Theme.secondaryColor)
                                    .font(.custom(Theme.bodyFont, size: 21))
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(3)
                                
                                Text("Log workouts, track progress, and share achievements with friends and the supportive SweatSync community.")
                                    .foregroundColor(Theme.secondaryColor)
                                    .font(.custom(Theme.bodyFont, size: 21))
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(3)
                            }
                            .padding(.horizontal, 35)
                            
                            //next button
                            NavigationLink(destination: OnboardingScreen2()) {
                                Text("Next")
                                    .frame(width: 170, height: 50)
                                    .font(.custom(Theme.headingFont, size: 16))
                                    .background(Theme.secondaryColor)
                                    .foregroundColor(.white)
                                    .cornerRadius(25)
                            }
                        }
                    )
                    .padding(40)
                Spacer()
            }
            .background(Color.black.ignoresSafeArea())
        }
    }
}

struct OnboardingScreen1_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingScreen1()
    }
}
