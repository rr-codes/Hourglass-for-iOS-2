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
    
    private let container: NSPersistentContainer
        
    init(_ storageType: StorageType) {
        self.container = NSPersistentContainer(name: "Model")
        
        switch storageType {
        case .persistant:
            let storeURL = URL.storeURL(for: "group.countdown2", databaseName: "group.countdown4")
            
            let description = NSPersistentStoreDescription(url: storeURL)
            description.shouldMigrateStoreAutomatically = true
            description.shouldInferMappingModelAutomatically = true
            
            self.container.persistentStoreDescriptions = [description]
            
        case .inMemory:
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            self.container.persistentStoreDescriptions = [description]
        }
        
        self.container.loadPersistentStores { _, _ in }
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
    
    public static func allEventsFetchRequest() -> NSFetchRequest<EventMO> {
        let request: NSFetchRequest<EventMO> = EventMO.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \EventMO.end, ascending: true)
        ]
        return request
    }
}
