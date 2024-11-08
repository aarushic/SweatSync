import SwiftUI


struct TemplatesView: View {
    // Sample data for templates
    let templates = ["Chest And Back", "Arms", "Legs", "Easy Run", "Speed Work"]
    
    var body: some View {
        NavigationView {
            VStack {
                // Title
                Text("Choose Template For Your Post")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.top, 20)
                
                // List of templates
                List {
//                    ForEach(templates, id: \.self) { template in
//                        NavigationLink(destination: TemplateDetailView(templateName: template)) {
//                            Text(template)
//                                .font(.body)
//                                .foregroundColor(.black)
//                                .padding()
//                        }
//                    }
                    
                    //get old templates from firebase
                }
                .frame(height: 400)
                .cornerRadius(10)
                Spacer()
                
                // "Create New Template" button
                NavigationLink(destination: NewTemplateView()) {
                    Text("Create new Template")
                        .font(.body)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color(red: 42/255, green: 42/255, blue: 42/255))
                        .cornerRadius(10)
                }
                .padding(.bottom, 30)
            }
            .padding()
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Templates")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// Detail view for each template (navigates to this when a template is selected)
struct TemplateDetailView: View {
    var templateName: String
    
    var body: some View {
        VStack {
            Text("Details for \(templateName)")
                .font(.largeTitle)
                .padding()
            Spacer()
        }
        .navigationTitle(templateName)
    }
}

// Create a new template view (navigates here when the button is tapped)
struct CreateTemplateView: View {
    var body: some View {
        VStack {
            Text("Create a New Template")
                .font(.largeTitle)
                .padding()
            Spacer()
        }
        .navigationTitle("New Template")
    }
}

struct TemplateSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        TemplatesView()
    }
}
