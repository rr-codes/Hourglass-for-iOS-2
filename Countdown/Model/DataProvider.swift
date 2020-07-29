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


class DataProvider: ObservableObject {
    static let shared = DataProvider()
    
    var context: NSManagedObjectContext {
        container.viewContext
    }
    
    lazy var defaults = UserDefaults(suiteName: "group.countdown2")

    lazy var container: NSPersistentContainer = {
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
    }()
    
    private init() {
        #if os(iOS)
        UnsplashImageValueTransformer.register()
        #endif
    }
    
    @discardableResult func save() -> Result<Bool, Error> {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
                return .success(true)
            } catch {
                return .failure(error)
            }
        }
        
        return .success(false)
    }
    
    public static func allEventsFetchRequest() -> NSFetchRequest<Event> {
        let request: NSFetchRequest<Event> = Event.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Event.end, ascending: true)
        ]
        return request
    }
}
