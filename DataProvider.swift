//
//  DataProvider.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-07-23.
//

import Foundation
import CoreData

public extension URL {
    /// Returns a URL for the given app group and database pointing to the sqlite database.
    static func storeURL(for appGroup: String, databaseName: String) -> URL {
        guard let fileContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else {
            fatalError("Shared file container could not be created.")
        }

        return fileContainer.appendingPathComponent("\(databaseName).sqlite")
    }
}


class DataProvider {
    static let shared = DataProvider()
    
    public static func allEventsFetchRequest() -> NSFetchRequest<Event> {
        let request: NSFetchRequest<Event> = Event.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Event.end, ascending: true)]
        return request
    }
    
    private init() {
        UnsplashImageValueTransformer.register()
    }
    
    var container: NSPersistentContainer {
        let pc = NSPersistentContainer(name: "Model")
        let storeURL = URL.storeURL(for: "group.countdown2", databaseName: "group.countdown2")
        let storeDescription = NSPersistentStoreDescription(url: storeURL)
        
        pc.persistentStoreDescriptions = [storeDescription]
        pc.loadPersistentStores { _, error in
            if let error = error {
                fatalError(error.localizedDescription)
            }
        }
        
        return pc
    }
    
    func addEvent(to context: NSManagedObjectContext, configuration: (name: String, start: Date, end: Date, emoji: String, image: UnsplashImage)) {
        let event = Event(context: context)
        let (name, start, end, emoji, image) = configuration
        
        event.id = UUID()
        event.name = name
        event.start = start
        event.end = end
        event.emoji = emoji
        event.image = image
    }
    
    func removeEvent(from context: NSManagedObjectContext, event: Event) {
        context.delete(event)
    }
}
