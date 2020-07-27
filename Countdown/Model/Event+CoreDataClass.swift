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
    typealias Properties = (name: String, start: Date, end: Date, emoji: String, image: UnsplashImage)
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Event> {
        return NSFetchRequest<Event>(entityName: "Event")
    }
    
    convenience init(emoji: String, end: Date, image: UnsplashImage, name: String, start: Date, insertInto context: NSManagedObjectContext) {
        self.init(context: context)
        self.id = UUID()
        
        self.emoji = emoji
        self.end = end
        self.image = image
        self.name = name
        self.start = start
    }

    @NSManaged public var emoji: String
    @NSManaged public var end: Date
    @NSManaged public var id: UUID
    @NSManaged public var image: UnsplashImage
    @NSManaged public var name: String
    @NSManaged public var start: Date
    
    var isOver: Bool {
        return end < Date()
    }
    
    var properties: Properties {
        (name, start, end, emoji, image)
    }
}
