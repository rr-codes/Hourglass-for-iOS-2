//
//  Event.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-08-05.
//

import Foundation
import CoreData

struct Event: Identifiable, Equatable {
    let id: UUID
    let name: String
    let start: Date
    let end: Date
    let image: UnsplashImage
    let emoji: String
    
    var isOver: Bool {
        end < Date()
    }
    
    init(_ name: String, end: Date, image: UnsplashImage, emoji: String, start: Date = Date(), id: UUID = UUID()) {
        self.id = id
        self.name = name
        self.start = start
        self.end = end
        self.image = image
        self.emoji = emoji
    }
    
    init?(bridged event: EventMO) {
        guard let id = event.id,
              let name = event.name,
              let end = event.end,
              let imageData = event.image,
              let emoji = event.emoji,
              let start = event.start
        else { return nil}
        
        guard let image = try? JSONDecoder().decode(UnsplashImage.self, from: imageData) else {
            return nil
        }
        
        self.init(name, end: end, image: image, emoji: emoji, start: start, id: id)
    }
}

extension EventMO {
    convenience init(bridged event: Event, context: NSManagedObjectContext) {
        self.init(context: context)
        
        self.id = event.id
        self.name = event.name
        self.start = event.start
        self.end = event.end
        self.emoji = event.emoji
        self.image = try? JSONEncoder().encode(event.image)
    }
}
