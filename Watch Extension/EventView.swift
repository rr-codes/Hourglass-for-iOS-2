//
//  EventView.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-09-04.
//

import SwiftUI

struct EventView: View {
    @EnvironmentObject var timer: ObservableTimer
        
    let name: String
    let endDate: Date
    let emoji: String
    let image: BackgroundImage
    
    let formatter: DateComponentsFormatter = {
        var dcf = DateComponentsFormatter()
        dcf.unitsStyle = .short
        dcf.maximumUnitCount = 2
        return dcf
    }()
    
    var body: some View {
        ZStack {
            AsyncImageView(url: image.url(for: .small), color: .black)
                .clipShape(Circle())
                .opacity(0.5)
                .blur(radius: 15.0)
                .scaleEffect(0.93)
                .offset(y: 10)
            
            VStack {
                Spacer().height(15)
                
                Circle()
                    .fill(Color.white)
                    .opacity(0.1)
                    .overlay(
                        Text(emoji).font(.title2)
                    )
                    .frame(width: 65, height: 65)
                
                Spacer().height(20)
                
                Text(formatter.string(from: timer.output, to: endDate)!)
                    .font(Font.system(size: 23, design: .rounded).monospacedDigit())
                    .bold()
            }
        }
        .navigationTitle(name)
    }
}

struct EventView_Previews: PreviewProvider {
    static let event = MockData.eventB
    
    static var previews: some View {
        EventView(name: event.name, endDate: event.end, emoji: event.emoji, image: event.image)
            .environmentObject(ObservableTimer.shared)
    }
}
