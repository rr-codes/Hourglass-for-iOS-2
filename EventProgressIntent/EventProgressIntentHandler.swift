//
//  EventProgressIntentHandler.swift
//  EventProgressIntent
//
//  Created by Richard Robinson on 2020-08-15.
//

import Foundation
import CoreData
import Intents

class IntentHandler: INExtension {
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        if intent is EventProgressIntent {
            return EventProgressIntentHandler()
        }
        
        fatalError()
    }
    
}

class EventProgressIntentHandler: NSObject, EventProgressIntentHandling {
    func handle(intent: EventProgressIntent, completion: @escaping (EventProgressIntentResponse) -> Void) {
        let name = intent.name!
        
        let predicate = NSComparisonPredicate(
            leftExpression: .init(forKeyPath: \Event.name),
            rightExpression: .init(forConstantValue: name),
            modifier: .direct,
            type: .like,
            options: [.caseInsensitive, .diacriticInsensitive]
        )
        
        let store = PersistenceController.shared
        
        let request: NSFetchRequest<EventMO> = EventMO.fetchRequest()
        request.predicate = predicate
        request.fetchLimit = 1
        
        do {
            let event = try store.container.viewContext.fetch(request).first
            let components = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: Date(), to: event?.end ?? Date())
            completion(.success(date: components, name: name))
        } catch {
            print(String(describing: error))
            completion(.failure(name: name))
        }
    }
    
    func resolveName(for intent: EventProgressIntent, with completion: @escaping (INStringResolutionResult) -> Void) {
        if let name = intent.name, !name.isEmpty {
            completion(.success(with: name))
        } else {
            completion(.needsValue())
        }
    }
}
