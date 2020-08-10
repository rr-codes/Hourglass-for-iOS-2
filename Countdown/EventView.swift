//
//  EventView.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-07-24.
//

import SwiftUI

struct EventView: View {
    @Environment(\.calendar) var calendar: Calendar
    
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
    
    func format(end: Date, numberOfDroppedUnits n: Int, using formatter: DateComponentsFormatter) -> String? {
        let now = Date()
        let inOneDay  = calendar.date(byAdding: .day, value: 1, to: now)!
        let inOneHour = calendar.date(byAdding: .hour, value: 1, to: now)!
        let inOneMin  = calendar.date(byAdding: .minute, value: 1, to: now)!
        
        let oneDayAgo  = calendar.date(byAdding: .day, value: -1, to: now)!
        let oneHourAgo = calendar.date(byAdding: .hour, value: -1, to: now)!
        let oneMinAgo  = calendar.date(byAdding: .minute, value: -1, to: now)!
                
        var units: [NSCalendar.Unit] = [.day, .hour, .minute, .second]
        
        if oneDayAgo...inOneDay ~= end {
            units.removeFirst()
        }
        
        if oneHourAgo...inOneHour ~= end {
            units.removeFirst()
        }
        
        if oneMinAgo...inOneMin ~= end {
            units.removeFirst()
        }
        
        formatter.allowedUnits = .init(units.dropFirst(n % units.count))
        return formatter.string(from: end.timeIntervalSince(now))
    }
    
    var gradientOverlay: LinearGradient {
        let gradient = Gradient(stops: [
            .init(color: Color.white.opacity(0.8), location: 0),
            .init(color: Color.white.opacity(0), location: 0.6)
        ])
        
        return .init(gradient: gradient, startPoint: .top, endPoint: .bottom)
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
                    
                    Text(self.format(end: event.end, numberOfDroppedUnits: counter, using: formatter) ?? "")
                        .font(Font.title2.weight(.semibold))
                        .foregroundColor(Color(white: 0.5))
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
        EventView(event: MockData.greece) {}
        .preferredColorScheme(.dark)
    }
}
