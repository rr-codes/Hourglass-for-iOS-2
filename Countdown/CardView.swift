//
//  CardView.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-07-23.
//

import SwiftUI

struct CardView: View {
    let imageURL: URL?
    let imageColor: Color
    let date: Date
    let emoji: String
    let name: String
    
    var formatter: DateComponentsFormatter {
        let dcf = DateComponentsFormatter()
        dcf.allowedUnits = [.day, .hour, .minute, .second]
        dcf.includesTimeRemainingPhrase = true
        dcf.unitsStyle = .full
        dcf.maximumUnitCount = 2
        return dcf
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .bottomTrailing) {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .overlay(
                       // AsyncImage(color: imageColor, url: imageURL!)
                        
                        Image("sample2").resizable()
                    )
                    .frame(height: 225)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .shadow(color: imageColor.opacity(0.1), radius: 2, x: 0, y: 2)
                    .padding(.top)
                
                EmojiView(emoji, radius: 14.0).padding()
            }
            .padding(.bottom, 6)
            
            Group {
                Text(name).font(.headline).padding(.bottom, 4)
                
                Text(formatter.string(from: date.timeIntervalSinceNow)!)
                    .font(.subheadline)
                    .opacity(0.5)
            }
            .padding(.leading, 4)
        }
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(
            imageURL: nil,
            imageColor: .blue,
            date: .init(timeIntervalSinceNow: 86400 - 60),
            emoji: "😍",
            name: "My Birthday"
        ).padding()
    }
}
