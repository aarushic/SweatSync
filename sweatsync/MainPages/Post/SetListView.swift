//
//  SetListView.swift
//  sweatsync
//
//  Created by Ashwin on 11/11/24.
//

import Foundation
import SwiftUI

struct SetListView: View {
    @Binding var sets: [(String, String)]
    var label: String
    var unit: String
    var repsUnit: String
    var onRemove: (Int) -> Void
    
    var body: some View {
        ForEach(0..<sets.count, id: \.self) { index in
            HStack {
                Text("\(label) #\(index + 1)").font(.custom(Theme.bodyFont, size: 14))
                Spacer()
                
                TextField("0", text: $sets[index].0)
                    .frame(width: 50)
                    .multilineTextAlignment(.trailing)
                    .font(.custom(Theme.bodyFont, size: 14))
                    .onSubmit {
                        dismissKeyboard()
                    }
                
                Text(unit).font(.custom(Theme.bodyFont, size: 14))
                
                Spacer()
                
                TextField("0", text: $sets[index].1)
                    .frame(width: 50)
                    .multilineTextAlignment(.trailing)
                    .font(.custom(Theme.bodyFont, size: 14))
                    .onSubmit {
                        dismissKeyboard()
                    }
                
                Text(repsUnit).font(.custom(Theme.bodyFont, size: 14))
                
                Button(action: { onRemove(index) }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
        }
    }
}
