//
//  CoreSpotlightConfiguration.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-07-27.
//

import Foundation
import CoreSpotlight
import CoreServices

class CSManager {
    private static let domainIdentifier = "com.richardrobinson.Countdown2.spotlight"
    
    public static let shared = CSManager(using: .default())
        
    private let index: CSSearchableIndex
        
    init(using index: CSSearchableIndex) {
        self.index = index
    }
    
    // MARK: Instance Functions
    
    private func attributeSet(id: UUID, name: String, date: Date) -> CSSearchableItemAttributeSet {
        let set = CSSearchableItemAttributeSet(contentType: .calendarEvent)
        set.startDate = date
        set.displayName = name
        set.title = name
        set.identifier = id.uuidString
        return set
    }
    
    public func add(id: UUID, name: String, date: Date) {
        let set = attributeSet(id: id, name: name, date: date)
        let item = CSSearchableItem(uniqueIdentifier: id.uuidString, domainIdentifier: Self.domainIdentifier, attributeSet: set)
        
        self.index.indexSearchableItems([item]) { (error) in
            if let error = error {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    public func remove(id: UUID) {
        self.index.deleteSearchableItems(withIdentifiers: [id.uuidString]) { (error) in
            if let error = error {
                fatalError(error.localizedDescription)
            }
        }
    }
}
