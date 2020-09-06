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
    public static let shared = CSManager(using: .default())
        
    private let index: CSSearchableIndex
    
    private var formatter: DateFormatter {
        let df = DateFormatter()
        df.dateStyle = .full
        df.timeStyle = .short
        return df
    }
        
    init(using index: CSSearchableIndex) {
        self.index = index
    }
    
    // MARK: Instance Functions
    
    private func attributeSet(id: UUID, name: String, date: Date) -> CSSearchableItemAttributeSet {
        let attributes = CSSearchableItemAttributeSet(contentType: .text)
        attributes.title = name
        attributes.contentDescription = formatter.string(from: date)
        attributes.identifier = id.uuidString
        attributes.relatedUniqueIdentifier = id.uuidString
        return attributes
    }
    
    public func index(id: UUID, name: String, date: Date) {
        let set = attributeSet(id: id, name: name, date: date)
        let item = CSSearchableItem(
            uniqueIdentifier: id.uuidString,
            domainIdentifier: nil,
            attributeSet: set
        )
        
        item.expirationDate = date
        
        self.index.indexSearchableItems([item]) { (error) in
            if let error = error {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    public func deindex(id: UUID) {
        self.index.deleteSearchableItems(withIdentifiers: [id.uuidString]) { (error) in
            if let error = error {
                fatalError(error.localizedDescription)
            }
        }
    }
}
