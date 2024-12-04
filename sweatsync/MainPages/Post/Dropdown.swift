//
//  Dropdown.swift
//  sweatsync
//
//  Created by Ashwin on 11/11/24.
//

import Foundation
import SwiftUI

struct Dropdown: View {
    @Binding var exerciseType: String
    
    var body: some View {
        Menu {
            Button(action: { exerciseType = "Strength Training" }) { Text("Strength Training").font(.custom(Theme.bodyFont, size: 16)) }
            Button(action: { exerciseType = "Sprints" }) { Text("Sprints").font(.custom(Theme.bodyFont, size: 16)) }
            Button(action: { exerciseType = "Distance Running" }) { Text("Distance Running").font(.custom(Theme.bodyFont, size: 16)) }
            Button(action: { exerciseType = "HIIT" }) { Text("HIIT").font(.custom(Theme.bodyFont, size: 16)) }
            Button(action: { exerciseType = "Biking" }) { Text("Biking").font(.custom(Theme.bodyFont, size: 16)) }
        } label: {
            HStack {
                Text(exerciseType.isEmpty ? "Select Exercise Type" : exerciseType)
                    .foregroundColor(exerciseType.isEmpty ? .gray : .black)
                    .font(.custom(Theme.bodyFont, size: 16))
                Spacer()
                Image(systemName: "chevron.down")
                    .foregroundColor(.white)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).stroke(Theme.primaryColor, lineWidth: 1))
        }
        .frame(maxWidth: .infinity)
    }
}
