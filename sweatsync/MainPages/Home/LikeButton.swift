//
//  LikeButton.swift
//  sweatsync
//
//  Created by Randy P on 10/23/24.
//

import SwiftUI

struct LikeButton: View {
    @State private var isLiked = false

    var body: some View {
        Button(action: {
            self.isLiked.toggle()
            
            //addtional actions such as storing into user id
            // into post
        }) {
            Image(systemName: isLiked ? "heart.fill" : "heart")
                .resizable()
                .frame(width:25, height:23)
                .foregroundStyle(isLiked ? Color(.accent) : Color(.white))
        }
        .buttonStyle(.borderless)

    }
}
