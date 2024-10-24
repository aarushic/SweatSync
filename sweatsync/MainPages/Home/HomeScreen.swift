//
//  HomeScreen.swift
//  sweatsync
//
//  Created by aarushi chitagi on 10/14/24.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct HomeScreenView: View {
    @State private var userName: String = ""

    var body: some View {
        VStack(spacing: 20) {
            
            HStack {
                //profile pic and info
                HStack {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(Color(red: 208/255, green: 247/255, blue: 147/255))

                    VStack(alignment: .leading) {
                        Text("Hi, \(userName)")
                            .font(.title3)
                            .bold()
                            .foregroundColor(.white)
                            .onAppear {
                                getUser()
                            }

                        Text("1 workout logged this week")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                // Search Icon
                Button(action: {
                    // Search action
                }) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(Color(red: 208/255, green: 247/255, blue: 147/255))
                        .font(.title)
                }
            }
            .padding(.horizontal)
            .padding(.top, 20)
            
            // Post feed
            // Replace individual cards with a ForLoop for each post
            List {
                WorkoutPostCard()
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.black)
                WorkoutPostCard()
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.black)
                WorkoutPostCard()
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.black)
            }
             .listStyle(.plain)
            //for loop of all posts that takes in parameters later
//            WorkoutPostCard()
            
            Spacer()

//            TabBarView()
        }
        .background(Color.black.ignoresSafeArea())
    }
    
    func getUser() {
            guard let user = Auth.auth().currentUser else {
                print("User not logged in")
                return
            }
                
            let userId = user.uid
            let db = Firestore.firestore()

            //get the user's document
            db.collection("users").document(userId).getDocument { document, error in
                if let error = error {
                    print("Error fetching user data: \(error.localizedDescription)")
                } else if let document = document, document.exists {
//                    print("data \(String(describing: document.data()))")
                    //get name
                    if let fetchedName = document.data()?["preferredName"] as? String {
                        self.userName = fetchedName
                    } else {
                        print("Error")
                    }
                }
            }
        }
}


struct HomeScreenPreview: PreviewProvider {
    static var previews: some View {
        HomeScreenView()
    }
}
