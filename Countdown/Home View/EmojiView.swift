//
//  EmojiView.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-07-23.
//

import SwiftUI

struct EmojiView: View {
    let emoji: String
    let radius: CGFloat
    
    init(_ emoji: String, radius: CGFloat) {
        precondition(emoji.count == 1)
        
        self.emoji = emoji
        self.radius = radius
    }
    
    var body: some View {
        ZStack {
            Circle().fill(Color.white.opacity(0.75))
            
            Text(emoji).font(.system(size: radius))
        }
        .frame(width: radius * 2, height: radius * 2)
    }
}

struct EmojiView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            EmojiView("😍", radius: 24.0)
                .frame(width: 60, height: 60)
                .background(Color.red)
                .previewLayout(.fixed(width: 60, height: 60))
            EmojiView("🎉", radius: 24.0)
                .frame(width: 60, height: 60)
                .background(Color.orange)
                .previewLayout(.fixed(width: 60, height: 56))
            EmojiView("🌎", radius: 24.0)
                .frame(width: 60, height: 60)
                .background(Color.blue)
                .previewLayout(.fixed(width: 60, height: 56))
        }

    }
}
