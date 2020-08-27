//
//  EventView.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-07-24.
//

import SwiftUI

struct MyToggleStyle: ToggleStyle {
    let width: CGFloat = 50
    
    func makeBody(configuration: Self.Configuration) -> some View {
        HStack {
            configuration.label

            ZStack(alignment: configuration.isOn ? .trailing : .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .frame(width: width, height: width / 2)
                    .foregroundColor(configuration.isOn ? .green : .red)
                
                RoundedRectangle(cornerRadius: 4)
                    .frame(width: (width / 2) - 4, height: width / 2 - 6)
                    .padding(4)
                    .foregroundColor(.white)
                    .onTapGesture {
                        withAnimation {
                            configuration.$isOn.wrappedValue.toggle()
                        }
                }
            }
        }
    }
}

struct EventView: View {
    @EnvironmentObject var timer: ObservableTimer

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
            from: (start: timer.output, end: event.end),
            numberOfDroppedUnits: counter,
            using: Calendar.current
        )
    }
            
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                AsyncImageView(url: event.image.url(for: .regular), color: Color(code: event.image.color))
                    .width(geometry.size.width)
                    .overlay(gradientOverlay)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Header("") {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.black)
                            .onTapGesture(perform: onDismiss)
                    }
                    .padding(.trailing, 20)
                    .padding(.top, 20)
                    
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
                    if let user = event.image.user {
                        HStack(spacing: 3) {
                            Text("Photo by")
                            
                            Text(user.name)
                                .underline()
                                .link(destination: user.url)

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
        }
        .confettiOverlay(event.emoji, emitWhen: $shouldEmitConfetti)
    }
}

struct EventView_Previews: PreviewProvider {
    static var previews: some View {
        EventView(event: MockData.eventB) {}
            .preferredColorScheme(.dark)
            .environmentObject(ObservableTimer.shared)
    }
}
