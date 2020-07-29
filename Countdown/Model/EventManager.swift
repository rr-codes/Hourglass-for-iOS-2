//
//  EventManager.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-07-28.
//

import Foundation
import CoreData

class EventManager {
    static func addEvent(to context: NSManagedObjectContext, configuration: Event.Properties) {
        let (name, start, end, emoji, image) = configuration
        
        let event = Event(context: context)
        event.id = UUID()
        event.start = start
        event.end = end
        event.name = name
        event.emoji = emoji
        event.image = image
        
        NotificationManager.shared.register(config: (name, emoji, end, event.id)) { (result) in
            switch result {
            case .success(let hasBeenRegistered):
                print("has been registered: \(hasBeenRegistered)")
                
            case .failure(let error):
                fatalError("error: \(error)")
            }
        }
        
        CSManager.shared.add(id: event.id, name: name, date: end)
        
        try! context.save()
    }
    
    static func removeEvent(from context: NSManagedObjectContext, event: Event) {
        context.delete(event)
        
        NotificationManager.shared.unregister(id: event.id)
        CSManager.shared.remove(id: event.id)
        
        try! context.save()
    }
}
