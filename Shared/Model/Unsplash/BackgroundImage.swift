//
//  BackgroundImage.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-09-04.
//

import Foundation

struct BackgroundImage: Identifiable, Codable, Hashable {
    struct Author: Codable, Hashable {
        let name: String
        let url: URL
    }
    
    enum Size: String, CaseIterable {
        case small, regular, full
    }
    
    internal let urls: [String : URL]
    
    let id: String
    
    let downloadEndpoint: URL?
    
    let color: Int
    
    let user: Author?
    
    func url(for size: Size) -> URL {
        urls[size.rawValue]!
    }
}

extension BackgroundImage: Equatable {
    static func == (lhs: BackgroundImage, rhs: BackgroundImage) -> Bool {
        lhs.id == rhs.id
    }
}
