//
//  AddSetButton.swift
//  sweatsync
//
//  Created by Ashwin on 11/11/24.
//

import Foundation
import SwiftUI

struct AddSetButton: View {
    var title: String
    var onAdd: () -> Void
    
    var body: some View {
        Button(action: { onAdd() }) {
            Text(title)
                .padding()
                .background(Color(red: 42/255, green: 42/255, blue: 42/255))
                .foregroundColor(.white)
                .cornerRadius(10)
                .font(.custom(Theme.bodyFont, size: 14))
        }
    }
}
