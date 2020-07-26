//
//  ListCellView.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-07-24.
//

import SwiftUI

class RelativeDateFormatter: DateComponentsFormatter {
    override func string(from ti: TimeInterval) -> String? {
        guard let string = super.string(from: abs(ti)) else {
            return nil
        }
        
        return "\(string) \(ti < 0 ? "ago" : "remaining")"
    }
}

struct ListCellView: View {
    let imageURL: URL
    let imageColor: Color
    let date: Date
    let emoji: String
    let name: String
    
    let size: CGFloat = 85
    
    var formatter: DateComponentsFormatter {
        let dcf = RelativeDateFormatter()
        dcf.allowedUnits = [.day, .hour, .minute, .second]
        dcf.unitsStyle = .full
        dcf.maximumUnitCount = 2
        return dcf
    }
    
    var body: some View {
        HStack {
            ZStack(alignment: .bottomTrailing) {
                AsyncImage(color: imageColor, url: imageURL)
                    .frame(width: size, height: size)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                    )
                    .shadow(color: imageColor.opacity(0.1), radius: 3, x: 0, y: 3)
                
                EmojiView(emoji, radius: 12).padding(6)
            }
            .padding(.trailing, 10)
            
            VStack(alignment: .leading) {
                Text(name)
                    .font(.headline)
                    .padding(.bottom, 4)
                    .padding(.top, 1)
                
                Text(formatter.string(from: date.timeIntervalSinceNow)!)
                    .font(.subheadline)
                    .opacity(0.5)
                
                Spacer()
            }
            
            Spacer()
        }
        .frame(height: size)
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
}

struct ListCellView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ListCellView(
                imageURL: MockImages.birthday.url(for: .regular),
                imageColor: .orange,
                date: .init(timeIntervalSinceNow: 86400 - 60),
                emoji: "🎉",
                name: "My Birthday"
            )
            
            
            ListCellView(
                imageURL: MockImages.birthday.url(for: .regular),
                imageColor: .orange,
                date: .init(timeIntervalSinceNow: 86400 - 60),
                emoji: "🎉",
                name: "My Birthday"
            )
        }
        
        
    }
}
