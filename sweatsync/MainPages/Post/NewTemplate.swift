import SwiftUI

struct NewTemplateView: View {
    @State private var templateName: String = ""
    @State private var dropdowns: [String] = []  // Array to track exercise type selection for each dropdown
    @State private var selectedExerciseType: String = "Exercise Type"

    var body: some View {
        NavigationView {
            VStack {
                
                // "New Template Name" TextField with camera icon
                HStack {
                    TextField("New Template Name", text: $templateName)
                        .textInputAutocapitalization(.words)
                        .padding()
                        .background(.white)
                        .cornerRadius(10)
                        .foregroundColor(.black)

                    // Camera icon button
                    Button(action: {
                        // Action for camera button
                    }) {
                        Image(systemName: "camera")
                            .resizable()
                            .frame(width: 40, height: 30)
                            .foregroundColor(.white)
                            .padding(.trailing)
                    }
                }
                .padding(.top, 10)
                
                Spacer()
                
                // Dynamic dropdowns
                ForEach(dropdowns.indices, id: \.self) { index in
                    Menu {
                        Button(action: {
                            dropdowns[index] = "Strength Training"
                        }) {
                            Text("Strength Training")
                        }
                        Button(action: {
                            dropdowns[index] = "Sprints"
                        }) {
                            Text("Sprints")
                        }
                        Button(action: {
                            dropdowns[index] = "Distance Running"
                        }) {
                            Text("Distance Running")
                        }
                        Button(action: {
                            dropdowns[index] = "HIIT"
                        }) {
                            Text("HIIT")
                        }
                        Button(action: {
                            dropdowns[index] = "Biking"
                        }) {
                            Text("Biking")
                        }
                    } label: {
                        HStack {
                            Text(dropdowns[index].isEmpty ? "Select Exercise Type" : dropdowns[index])
                                .foregroundColor(.white)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.black)
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 2))
                    }
                    .padding(.horizontal)
                }
                
                // Floating "Add" button with avatar beside it
                HStack(spacing: -20) {
                    Button(action: {
                        // Add new dropdown
                        dropdowns.append("")  // Append an empty dropdown when + is pressed
                    }) {
                        Image(systemName: "plus.circle")
                            .resizable()
                            .frame(width: 50, height: 50)
                    }
                }
                .padding(.top, 20)
                
                // "Post" Button
                Button(action: {
                    // Action for Post button
                }) {
                    Text("Post")
                        .font(.body)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color(red: 42/255, green: 42/255, blue: 42/255))
                        .cornerRadius(10)
                }
                .padding(.top, 30)
                
                Spacer()
            }
            .padding()
            .background(Color.black.ignoresSafeArea()) // Set background to black
            .navigationTitle("New Template")
            .navigationBarTitleDisplayMode(.inline) // Small title with back button
        }
    }
}

struct NewTemplateScreen_Previews: PreviewProvider {
    static var previews: some View {
        NewTemplateView()
    }
}
