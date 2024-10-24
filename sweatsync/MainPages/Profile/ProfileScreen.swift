import SwiftUI

struct ProfileScreen: View {
    var body: some View {
        NavigationView {
            VStack {
                Spacer()

                VStack {
                    // User's name
                    Text("Name")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.white)
                        .padding(.top, 20)
                    
                    // Profile picture (Placeholder)
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.gray)
                        .padding(.top, 10)
                    
                    // Bio
                    Text("bio")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.top, 5)
                    
                    // Streak Section (Fire emoji and days)
                    HStack {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                        Text("22 Days")
                            .foregroundColor(.white)
                            .bold()
                    }
                    .padding(.top, 10)
                }
                .padding(.bottom, 20)
                .background(Color.black)
                
                // Follower and Following stats
                HStack {
                    StatView(statNumber: "3", statLabel: "followers")
                    Spacer()
                    StatView(statNumber: "5", statLabel: "following")
                }
                .padding(.horizontal, 40)
                .padding(.top, 20)

                
                Spacer()
                
            }
            .edgesIgnoringSafeArea(.all)
            .background(Color.black)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.white)
                            .imageScale(.large)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct StatView: View {
    let statNumber: String
    let statLabel: String
    
    var body: some View {
        VStack {
            Text(statNumber)
                .font(.title)
                .bold()
                .foregroundColor(.white)
            Text(statLabel)
                .font(.caption)
                .foregroundColor(.white)
        }
        .frame(width: 100, height: 50)
        .background(Color.gray.opacity(0.3))
        .cornerRadius(10)
    }
}

struct AchievementView: View {
    let title: String
    let iconName: String
    
    var body: some View {
        VStack {
            Image(systemName: iconName)
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundColor(.yellow)
            Text(title)
                .font(.headline)
                .bold()
                .foregroundColor(.white)
        }
    }
}

#Preview {
    ProfileScreen()
}
