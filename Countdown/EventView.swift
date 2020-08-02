//
//  EventView.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-07-24.
//

import SwiftUI

struct EventView: View {
    @State var now: Date = Date()
    @State var counter = 0
    @State var shouldEmitConfetti = false

    let image: UnsplashImage
    let name: String
    let date: Date
    let emoji: String
    
    let onDismiss: () -> Void
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
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
    
    func format(_ interval: (start: Date, end: Date), numberOfDroppedUnits n: Int, using formatter: DateComponentsFormatter) -> String? {
        let inOneDay  = Calendar.current.date(byAdding: .day, value: 1, to: interval.start)!
        let inOneHour = Calendar.current.date(byAdding: .hour, value: 1, to: interval.start)!
        let inOneMin  = Calendar.current.date(byAdding: .minute, value: 1, to: interval.start)!
        
        let oneDayAgo  = Calendar.current.date(byAdding: .day, value: -1, to: interval.start)!
        let oneHourAgo = Calendar.current.date(byAdding: .hour, value: -1, to: interval.start)!
        let oneMinAgo  = Calendar.current.date(byAdding: .minute, value: -1, to: interval.start)!
                
        var units: [NSCalendar.Unit] = [.day, .hour, .minute, .second]
        
        if oneDayAgo...inOneDay ~= interval.end {
            units.removeFirst()
        }
        
        if oneHourAgo...inOneHour ~= interval.end {
            units.removeFirst()
        }
        
        if oneMinAgo...inOneMin ~= interval.end {
            units.removeFirst()
        }
        
        formatter.allowedUnits = .init(units.dropFirst(n % units.count))
        return formatter.string(from: interval.end.timeIntervalSince(interval.start))
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
                    
                    Text(self.format((start: now, end: date), numberOfDroppedUnits: counter, using: formatter) ?? "")
                        .font(Font.title2.weight(.semibold))
                        .foregroundColor(Color(white: 0.5))
                        .onTapGesture {
                            self.counter += 1
                        }
                    
                    Spacer()
                    
                    HStack(spacing: 3) {
                        Text("Photo by")
                        Link(destination: image.user.links["html"]!) { Text(image.user.name).underline()
                        }
                        Text("on")
                        Link(destination: unsplashLink!) { Text("Unsplash").underline() }
                        
                        Spacer()
                    }
                    .font(.caption)
                    .foregroundColor(Color.black.opacity(0.5))
                    .padding(.leading, 20)
                }
            }
        }
        .onReceive(timer) {
            self.now = $0
            if -1...0 ~= self.date.timeIntervalSince(self.now) {
                self.shouldEmitConfetti = true
            }
        }
        .confettiOverlay(self.emoji, emitWhen: $shouldEmitConfetti)
    }
}

struct EventView_Previews: PreviewProvider {
    @Namespace static var namespace
    
    static let (name, _, end, emoji, image) = MockData.greece
    
    static var previews: some View {
        EventView(
            image: image,
            name: name,
            date: Date(timeIntervalSinceNow: 20),
            emoji: emoji
        ) {}
    }
}
