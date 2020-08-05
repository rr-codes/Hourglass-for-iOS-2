//
//  URLExtensions.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-08-04.
//

import Foundation

extension URL {
    static let deepLinkScheme = "com.richardrobinson.hourglass"
    static let viewEventHost = "view_event"
    
    var components: URLComponents? {
        URLComponents(url: self, resolvingAgainstBaseURL: false)
    }
}
