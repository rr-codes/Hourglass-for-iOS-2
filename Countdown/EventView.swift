//
//  EventView.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-07-24.
//

import SwiftUI



struct EventView: View {
    let image: UnsplashImage
    let name: String
    let date: Date
    let emoji: String
    
    let onDismiss: () -> Void
    
    @State var numberOfDroppedUnits = 0
    
    var unsplashLink: URL? {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "unsplash.com"
        urlComponents.queryItems = [
            URLQueryItem(name: "utm_source", value: "Hourglass"),
            URLQueryItem(name: "utm_medium", value: "referral")
        ]
        
        return urlComponents.url
    }
    
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
            .init(color: Color.white.opacity(0.8), location: 0),
            .init(color: Color.white.opacity(0), location: 0.6)
        ])
        
        return .init(gradient: gradient, startPoint: .top, endPoint: .bottom)
    }
    
//    TextBuilder.TextType.normal("Photo by")
//    .link(image.user.name, url: image.user.links["html"])
//    .normal("on")
//    .link("Unsplash", url: unsplashLink)
            
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                AsyncImage(color: image.overallColor, url: image.url(for: .regular))
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
                            .onTapGesture(perform: onDismiss)
                    }
                    
                    EmojiView(emoji, radius: 18.0)
                        .background(Color.black.opacity(0.3).clipShape(Circle()))
                        .padding(.top, 15)
                    
                    Text(name)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(Color.black.opacity(0.9))
                    
                    Spacer().height(8)
                    
                    Text(formatter.string(from: date.timeIntervalSinceNow)!)
                        .font(Font.title2.weight(.semibold))
                        .foregroundColor(Color(white: 0.5))
                        .onTapGesture {
                            self.numberOfDroppedUnits = (self.numberOfDroppedUnits + 1) % 4
                        }
                    
                    Spacer()
                    
                    HStack {
                        FancyText {
                            TextType.normal("Photo by")
                            
                            TextType.link(image.user.name, url: image.user.links["html"])
                            
                            TextType.normal("on")
                            
                            TextType.link("Unsplash", url: unsplashLink)
                        }
                        .font(.caption)
                        .foregroundColor(Color.black.opacity(0.5))
                        
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
    
    static let (name, _, end, emoji, image) = MockData.greece
    
    static var previews: some View {
        EventView(
            image: image,
            name: name,
            date: end,
            emoji: emoji
        ) {}
    }
}
