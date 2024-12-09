//
//  OnboardingScreen3.swift
//  sweatsync
//
//  Created by aarushi chitagi on 10/14/24.
//

import Foundation
import SwiftUI

struct OnboardingScreen3: View {
    @EnvironmentObject var session: SessionManager

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
                            Image(systemName: "clipboard.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                                .foregroundColor(Theme.secondaryColor)
                            
                            //text
                            Text("Stay Motivated with Rewards and Challenges")
                                .foregroundColor(.black)
                                .font(.custom(Theme.headingFont, size: 23))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 9)
                            
                            VStack(spacing: 30){
                                Text("Earn badges, build streaks, and climb leaderboards!")
                                    .foregroundColor(Theme.secondaryColor)
                                    .font(.custom(Theme.bodyFont, size: 17))
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(3)
                                
                                Text("Engage with friends, challenge each other, and celebrate milestones together in an exciting, community-driven fitness experience.")
                                    .foregroundColor(Theme.secondaryColor)
                                    .font(.custom(Theme.bodyFont, size: 17))
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(3)
                            }
                            .padding(.horizontal, 35)
                            
                            //next button
                            NavigationLink(destination: TabBarView().onAppear {
                                session.signIn()
                            }) {
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

struct Previews5: PreviewProvider {
    static var previews: some View {
        OnboardingScreen3()
    }
}
