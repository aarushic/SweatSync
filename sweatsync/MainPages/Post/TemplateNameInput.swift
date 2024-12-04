//
//  TemplateNameInput.swift
//  sweatsync
//
//  Created by Ashwin on 11/11/24.
//

import Foundation
import SwiftUI

struct TemplateNameInput: View {
    @Binding var templateName: String
    
    var body: some View {
        HStack {
            TextField("New Post Name", text: $templateName)
                .textInputAutocapitalization(.words)
                .font(.custom(Theme.bodyFont, size: 16))
                .padding()
                .background(.white)
                .cornerRadius(10)
                .foregroundColor(.black)
                .onSubmit {
                    dismissKeyboard()
                }
        }
        .padding(.top, 10)
    }
}

