//
//  CardView.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-07-23.
//

import SwiftUI

struct CardView: View {
    let data: Event.Properties
    
    let namespace: Namespace.ID
    let isSource: Bool
    let id: UUID
    
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
                AsyncImage(color: data.image.overallColor, url: data.image.url(for: .regular))
                    .matchedGeometryEffect(id: id, in: namespace, isSource: isSource)
                    .frame(height: 225)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .shadow(color: data.image.overallColor.opacity(0.1), radius: 2, x: 0, y: 2)
                    .padding(.top)
                
                EmojiView(data.emoji, radius: 14.0).padding()
            }
            .padding(.bottom, 6)
            
            Group {
                Text(data.name).font(.headline).padding(.bottom, 4)
                
                Text(formatter.string(from: data.end.timeIntervalSinceNow)!)
                    .font(.subheadline)
                    .opacity(0.5)
            }
            .padding(.leading, 4)
        }
    }
}

struct CardView_Previews: PreviewProvider {
    @Namespace static var namespace
    
    static let props: Event.Properties = (
        name: "My Birthday",
        start: Date(),
        end: Date().addingTimeInterval(86400),
        emoji: "🎉",
        image: MockImages.birthday
    )
    
    static var previews: some View {
        CardView(
            data: props,
            namespace: namespace,
            isSource: true,
            id: .init()
        ).padding()
    }
}
