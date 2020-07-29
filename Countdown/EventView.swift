//
//  EventView.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-07-24.
//

import SwiftUI

struct EventView: View {
    let id: UUID
    let namespace: Namespace.ID
    
    let image: UnsplashImage
    let name: String
    let date: Date
    let emoji: String
    
    let onDismiss: () -> Void
    
    @State var numberOfDroppedUnits = 0
    
    var formatter: DateComponentsFormatter {
        let dcf = DateComponentsFormatter()
        let units: [NSCalendar.Unit] = [.day, .hour, .minute, .second]
        
        dcf.allowedUnits = NSCalendar.Unit(units.dropFirst(numberOfDroppedUnits))
        dcf.unitsStyle = .short
        dcf.maximumUnitCount = 2
        return dcf
    }
    
    var gradientOverlay: LinearGradient {
        let gradient = Gradient(stops: [
            .init(color: Color.black.opacity(0.8), location: 0),
            .init(color: Color.black.opacity(0), location: 0.6)
        ])
        
        return .init(gradient: gradient, startPoint: .top, endPoint: .bottom)
    }
            
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                AsyncImage(color: image.overallColor, url: image.url(for: .full))
                    .onTapGesture(perform: onDismiss)
                    .matchedGeometryEffect(id: id, in: namespace)
                    .width(geometry.size.width)
                    .overlay(gradientOverlay)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: "xmark.circle.fill")
                            .imageScale(.large)
                            .scaleEffect(1.2)
                            .background(Color.white.clipShape(Circle()))
                            .offset(x: -3, y: -0)
                            .padding(.top, 30)
                            .padding(.trailing, 20)
                    }
                    
                    EmojiView(emoji, radius: 18.0)
                        .background(Color.gray.opacity(0.8).clipShape(Circle()))
                        .padding(.top, 10)
                    
                    Text(name)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(Color.white.opacity(0.9))
                    
                    Spacer().height(8)
                    
                    Text(formatter.string(from: date.timeIntervalSinceNow)!)
                        .font(Font.title2.weight(.semibold))
                        .foregroundColor(Color(white: 0.9))
                        .onTapGesture {
                            self.numberOfDroppedUnits = (self.numberOfDroppedUnits + 1) % 4
                        }
                    
                    Spacer()
                    
                    HStack {
                        Text("Photo by @\(image.user.username)")
                            .font(.caption)
                            .opacity(0.8)
                        
                        Spacer()
                    }
                    .padding(.leading, 20)
                }
            }
        }
    }
}

struct EventView_Previews: PreviewProvider {
    @Namespace static var namespace
    
    static var previews: some View {
        EventView(
            id: UUID(),
            namespace: namespace,
            image: MockImages.birthday,
            name: "Travelling to Greece",
            date: .init(timeIntervalSinceNow: 86400 - 60),
            emoji: "🇬🇷"
        ) {}
    }
}
