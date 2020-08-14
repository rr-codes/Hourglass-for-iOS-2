//
//  EventView.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-07-24.
//

import SwiftUI

struct EventView: View {    
    @State var counter = 0
    @State var shouldEmitConfetti = false

    let event: Event
    
    let onDismiss: () -> Void
        
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
        dcf.allowedUnits = [.day, .hour, .minute, .second]
        dcf.unitsStyle = .short
        dcf.maximumUnitCount = 2
        return dcf
    }
    
    var gradientOverlay: LinearGradient {
        let gradient = Gradient(stops: [
            .init(color: Color.white.opacity(0.7), location: 0),
            .init(color: Color.white.opacity(0), location: 1)
        ])
        
        return .init(gradient: gradient, startPoint: .top, endPoint: .bottom)
    }
    
    var formattedString: String? {
        formatter.string(
            from: (start: Date(), end: event.end),
            numberOfDroppedUnits: counter,
            using: Calendar.current
        )
    }
            
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                AsyncImage(color: event.image.overallColor, url: event.image.url(for: .regular))
                    .width(geometry.size.width)
                    .overlay(gradientOverlay)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: "xmark.circle.fill")
                            .renderingMode(.original)
                            .foregroundColor(.black)
                            .imageScale(.large)
                            .scaleEffect(1.2)
                            .background(Color.white.clipShape(Circle()))
                            .offset(x: -3, y: -0)
                            .padding(.top, 30)
                            .padding(.trailing, 20)
                            .onTapGesture(perform: onDismiss)
                    }
                    
                    EmojiView(event.emoji, radius: 18.0)
                        .background(Color.black.opacity(0.3).clipShape(Circle()))
                        .padding(.top, 15)
                    
                    Text(event.name)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(Color.black.opacity(0.9))
                    
                    Spacer().height(8)
                    
                    Text(formattedString ?? "")
                        .font(Font.title2.weight(.semibold))
                        .foregroundColor(Color.black.opacity(0.7))
                        .onTapGesture {
                            self.counter += 1
                        }
                    
                    
                    Spacer()
                    
                    HStack(spacing: 3) {
                        Text("Photo by")
                        
                        Text(event.image.user.name)
                            .underline()
                            .link(destination: event.image.user.links["html"])

                        Text("on")
                        
                        Text("Unsplash")
                            .underline()
                            .link(destination: unsplashLink)
                                                
                        Spacer()
                    }
                    .font(.caption)
                    .foregroundColor(Color.black.opacity(0.5))
                    .padding(.leading, 20)
                }
            }
        }
        .confettiOverlay(event.emoji, emitWhen: $shouldEmitConfetti)
    }
}

struct EventView_Previews: PreviewProvider {
    static var previews: some View {
        EventView(event: MockData.eventB) {}
        .preferredColorScheme(.dark)
    }
}
