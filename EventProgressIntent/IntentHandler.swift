//
//  IntentHandler.swift
//  EventProgressIntent
//
//  Created by Richard Robinson on 2020-07-27.
//

import Intents
import CoreData

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
        
        let container = CoreDataStore.shared.container
        let request: NSFetchRequest<Event> = Event.fetchRequest()
        request.predicate = predicate
        request.fetchLimit = 1
        
        do {
            let event = try container.viewContext.fetch(request).first!
            let components = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: Date(), to: event.end)
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
