//
//  EventView.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-07-24.
//

import SwiftUI

struct EventView: View {
    let id: UUID
    let image: String
    let name: String
    let date: Date
    let emoji: String
    
    let namespace: Namespace.ID
    
    var body: some View {
        Image(image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .edgesIgnoringSafeArea(.all)
            .matchedGeometryEffect(id: id, in: namespace)
    }
}

struct EventView_Previews: PreviewProvider {
    @Namespace static var namespace
    
    static var previews: some View {
        EventView(
            id: .init(),
            image: "sample2",
            name: "My Birthday",
            date: .init(timeIntervalSinceNow: 86400 - 60),
            emoji: "😍",
            namespace: namespace
        )
    }
}
