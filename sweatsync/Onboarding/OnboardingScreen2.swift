//
//  OnboardingScreen2.swift
//  sweatsync
//
//  Created by aarushi chitagi on 10/14/24.
//

import Foundation
import SwiftUI

struct OnboardingScreen2: View {
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                //green box
                RoundedRectangle(cornerRadius: 20)
                    .fill(Theme.primaryColor)
                    .frame(height: 570)
                    .overlay(
                        VStack(spacing: 20) {
                            //icon
                            Image(systemName: "person.3.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                                .foregroundColor(Theme.secondaryColor)
                            
                            //text
                            Text("Customized Workouts and Goals")
                                .foregroundColor(.black)
                                .font(.custom(Theme.headingFont, size: 23))
                                .multilineTextAlignment(.center)
                            
                            VStack(spacing: 30){
                                Text("Create custom exercise plans and set your personal fitness goals.")
                                    .foregroundColor(Theme.secondaryColor)
                                    .font(.custom(Theme.bodyFont, size: 17))
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(3)
                                
                                Text("Whether it’s strength training, running, or cycling, SweatSync adapts to your unique journey, making it easy to stay organized and focused.")
                                    .foregroundColor(Theme.secondaryColor)
                                    .font(.custom(Theme.bodyFont, size: 17))
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(3)
                            }
                            .padding(.horizontal, 35)
                            
                            //next button
                            NavigationLink(destination: OnboardingScreen3()) {
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

struct Previews4: PreviewProvider {
    static var previews: some View {
        OnboardingScreen2()
    }
}
