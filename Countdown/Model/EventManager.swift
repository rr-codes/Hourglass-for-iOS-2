//
//  EventManager.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-07-28.
//

import Foundation
import CoreData

class EventManager {
    static let shared: EventManager = EventManager(notificationManager: .shared, spotlightManager: .shared)
    
    private let notificationManager: NotificationManager
    private let spotlightManager: CSManager
    
    init(notificationManager: NotificationManager, spotlightManager: CSManager) {
        self.notificationManager = notificationManager
        self.spotlightManager = spotlightManager
    }
    
    func addEvent(to context: NSManagedObjectContext, configuration: Event.Properties) {
        let (name, start, end, emoji, image) = configuration
        
        let event = Event(context: context)
        event.id = UUID()
        event.start = start
        event.end = end
        event.name = name
        event.emoji = emoji
        event.image = image
        
        self.notificationManager.register(config: (name, emoji, end, event.id)) { (result) in
            switch result {
            case .success(let hasBeenRegistered):
                print("has been registered: \(hasBeenRegistered)")
                
            case .failure(let error):
                fatalError("error: \(error)")
            }
        }
        
        self.spotlightManager.add(id: event.id, name: name, date: end)
        
        try! context.save()
    }
    
    func removeEvent(from context: NSManagedObjectContext, event: Event) {
        context.delete(event)
        
        self.notificationManager.unregister(id: event.id)
        self.spotlightManager.remove(id: event.id)
        
        try! context.save()
    }
}
