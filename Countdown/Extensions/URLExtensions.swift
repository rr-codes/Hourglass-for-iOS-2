//
//  URLExtensions.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-08-04.
//

import Foundation

extension URL {
    static let appScheme = "com.richardrobinson.hourglass"
    
    struct Hosts {
        static let addEvent = "addEvent"
        static let viewPinned = "viewPinned"
    }
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
