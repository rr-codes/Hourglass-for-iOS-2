//
//  EventManager.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-07-28.
//

import Foundation
import CoreData
import WidgetKit

class EventManager {
    static let shared = EventManager(
        notificationManager: .shared,
        spotlightManager: .shared,
        widgetCenter: .shared
    )
    
    private let notificationManager: NotificationManager
    private let spotlightManager: CSManager
    private let widgetCenter: WidgetCenter
    
    init(
        notificationManager: NotificationManager,
        spotlightManager: CSManager,
        widgetCenter: WidgetCenter
    ) {
        self.notificationManager = notificationManager
        self.spotlightManager = spotlightManager
        self.widgetCenter = widgetCenter
    }
    
    func reindex(_ event: Event) {
        self.spotlightManager.index(id: event.id, name: event.name, date: event.end)
    }
    
    func addEvent(to context: NSManagedObjectContext, event: Event) {
        let _ = EventMO(bridged: event, context: context)
        
        self.notificationManager.register(event) { (result) in
            switch result {
            case .success(let hasBeenRegistered):
                print("has been registered: \(hasBeenRegistered)")
                
            case .failure(let error):
                print("error: \(error)")
            }
        }
        
        self.reindex(event)
        
        try? context.save()
        
        self.widgetCenter.reloadAllTimelines()
    }
    
    func removeEvent(from context: NSManagedObjectContext, event: Event) {
        let request: NSFetchRequest<EventMO> = EventMO.fetchRequest()
        
        request.predicate = NSComparisonPredicate(
            leftExpression: .init(forKeyPath: \EventMO.id),
            rightExpression: .init(forConstantValue: event.id),
            modifier: .direct,
            type: .equalTo
        )
        
        request.fetchLimit = 1
        
        if let result = try? context.fetch(request).first {
            context.delete(result)
        }
                
        self.notificationManager.unregister(id: event.id)
        self.spotlightManager.deindex(id: event.id)
        
        try? context.save()
        
        self.widgetCenter.reloadAllTimelines()
    }
}
