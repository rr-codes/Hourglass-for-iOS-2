//
//  DataProvider.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-07-23.
//

import Foundation
import CoreData

public extension UserDefaults {
    static let appGroup: UserDefaults? = UserDefaults(suiteName: "group.countdown2")
}

public extension URL {
    /// Returns a URL for the given app group and database pointing to the sqlite database.
    static func storeURL(for appGroup: String, databaseName: String) -> URL {
        guard let fileContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else {
            fatalError("Shared file container could not be created.")
        }

        return fileContainer.appendingPathComponent("\(databaseName).sqlite")
    }
}

enum StorageType {
    case persistant, inMemory
}

class CoreDataStore: ObservableObject {
    static let shared = CoreDataStore(.persistant)
    
    var context: NSManagedObjectContext {
        container.viewContext
    }
    
    let container: NSPersistentContainer
    
    init(_ storageType: StorageType) {
        #if os(iOS) && !WIDGET
        UnsplashImageValueTransformer.register()
        #endif
        
        self.container = NSPersistentContainer(name: "Model")
        
        switch storageType {
        case .persistant:
            let storeURL = URL.storeURL(for: "group.countdown2", databaseName: "group.countdown2")
            let description = NSPersistentStoreDescription(url: storeURL)
            self.container.persistentStoreDescriptions = [description]
            
        case .inMemory:
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            self.container.persistentStoreDescriptions = [description]
        }
        
        self.container.loadPersistentStores { _, error in
            if let error = error {
                fatalError(error.localizedDescription)
            }
        }
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
