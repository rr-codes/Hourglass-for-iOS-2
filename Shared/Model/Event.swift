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
    let emoji: String
    
    let image: BackgroundImage
    
    var isOver: Bool {
        end < Date()
    }
    
    static func == (lhs: Event, rhs: Event) -> Bool {
        lhs.id == rhs.id
    }
}

extension Event {
    init?(bridged: EventMO) {
        guard let id = bridged.id,
           let name = bridged.name,
           let start = bridged.start,
           let end = bridged.end,
           let emoji = bridged.emoji,
           let image = bridged.image
        else {
            return nil
        }
        
        guard let decodedImage = try? JSONDecoder().decode(BackgroundImage.self, from: image) else {
            return nil
        }
        
        self.id = id
        self.name = name
        self.start = start
        self.end = end
        self.emoji = emoji
        self.image = decodedImage
    }
}

extension EventMO {
    convenience init(bridged: Event, context: NSManagedObjectContext) {
        self.init(context: context)
        
        self.id = bridged.id
        self.name = bridged.name
        self.start = bridged.start
        self.end = bridged.end
        self.emoji = bridged.emoji
        self.image = try! JSONEncoder().encode(bridged.image)
    }
}
