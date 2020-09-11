//
//  DataProvider.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-07-23.
//

import Foundation
import CoreData
import SwiftUI

public extension UserDefaults {
    static let appGroup: UserDefaults? = UserDefaults(suiteName: "group.countdown2")
}

struct PersistenceController {
    static let shared = PersistenceController()
    
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let context = result.container.viewContext
        
        for event in MockData.all {
            let _ = EventMO(bridged: event, context: context)
        }
        
        do {
            try context.save()
        } catch {
            fatalError("Unresolved error \(error as NSError)")
        }
        
        return result
    }()
    
    let container: NSPersistentCloudKitContainer
    
    init(inMemory: Bool = false) {
        self.container = NSPersistentCloudKitContainer(name: "Model")
        
        if inMemory {
            self.container.persistentStoreDescriptions[0].url = URL(fileURLWithPath: "/dev/null")
        } else if let storeURL = URL.storeURL(for: "group.countdown2", databaseName: "Model") {
            let storeDescription = NSPersistentStoreDescription(url: storeURL)
            self.container.persistentStoreDescriptions = [storeDescription]
        }
        
        self.container.persistentStoreDescriptions[0].setOption(
            true as NSNumber,
            forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey
        )
        
        self.container.persistentStoreDescriptions[0].setOption(
            true as NSNumber,
            forKey: NSPersistentHistoryTrackingKey
        )
        
        self.container.loadPersistentStores { (_, error) in
            guard error == nil else {
                print("error loading store: \(error.debugDescription)")
                return
            }
        }
        
        self.container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    func save() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print(String(describing: error))
            }
        }
    }
    
    static func allEventsFetchRequest() -> NSFetchRequest<EventMO> {
        let request: NSFetchRequest<EventMO> = EventMO.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \EventMO.end, ascending: true)
        ]
        return request
    }
}
