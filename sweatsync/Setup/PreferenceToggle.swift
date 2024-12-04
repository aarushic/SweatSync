//
//  PreferenceToggle.swift
//  sweatsync
//
//  Created by Ashwin on 11/11/24.
//

import Foundation
import SwiftUI

struct PreferenceToggle: View {
    let title: String
    @Binding var isSelected: Bool
    
    var body: some View {
        Button(action: {
            isSelected.toggle()
        }) {
            Text(title)
                .font(.custom(Theme.bodyFont, size: 16))
                .foregroundColor(isSelected ? .black : .white)
                .frame(maxWidth: .infinity, minHeight: 50)
                .background(isSelected ? Theme.primaryColor : Theme.secondaryColor)
                .cornerRadius(10)
        }
    }
}
