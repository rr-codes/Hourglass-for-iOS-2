//
//  Event+CoreDataClass.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-07-24.
//
//

import Foundation
import CoreData

@objc(Event)
public class Event: NSManagedObject, Identifiable {
    struct Properties {
        let name: String
        let end: Date
        let emoji: String
        let image: UnsplashImage?
    }
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Event> {
        return NSFetchRequest<Event>(entityName: "Event")
    }

    @NSManaged public var emoji: String
    @NSManaged public var end: Date
    @NSManaged public var id: UUID
    @NSManaged public var image: UnsplashImage?
    @NSManaged public var name: String
    
    var isOver: Bool {
        return end < Date()
    }
    
    var properties: Properties {
        Properties(name: name, end: end, emoji: emoji, image: image)
    }
}
