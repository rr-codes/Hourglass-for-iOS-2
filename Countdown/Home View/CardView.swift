//
//  CardView.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-07-23.
//

import SwiftUI

struct CardView: View {
    @EnvironmentObject var timer: ObservableTimer

    let data: Event

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
                AsyncImageView(url: data.image.url(for: .regular), color: Color(code: data.image.color))
                    .frame(height: 225)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .shadow(color: Color(code: data.image.color).opacity(0.1), radius: 2, x: 0, y: 2)
                    .padding(.top)
                
                EmojiView(data.emoji, radius: 14.0).padding()
            }
            .padding(.bottom, 6)
            
            Group {
                Text(data.name).font(.headline)
                
                Spacer().height(5)
                
                Text(formatter.string(from: data.end.timeIntervalSince(timer.output))!)
                    .font(.subheadline)
                    .opacity(0.5)
            }
            .padding(.leading, 4)
        }
    }
}

struct CardView_Previews: PreviewProvider {
    @Namespace static var namespace
    
    static let props = Event(
        id: UUID(),
        name: "My Birthday",
        end: Date().addingTimeInterval(86400),
        emoji: "🎉",
        image: MockImages.birthday
    )
    
    static var previews: some View {
        CardView(data: props).padding()
    }
}
