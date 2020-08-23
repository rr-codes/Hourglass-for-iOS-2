//
//  UnsplashImage.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-08-15.
//

import Foundation

struct User: Codable {
    struct Links: Codable {
        let html: URL
    }
    
    let links: Links
    let name: String
}

struct RemoteImage: Identifiable, Codable {
    let id: String
    let color: String?
    let user: User?
    
    let urls: URLs
    let links: Links?
    
    init(from data: Data, using fileManager: FileManager) {
        self.id = UUID().uuidString
        self.user = nil
        self.color = nil
        
        let url = try! fileManager.saveImage(at: id, with: data)
        
        self.urls = URLs(full: url, regular: url, small: url)
        self.links = nil
    }
}

extension RemoteImage {
    struct Links: Codable {
        let download_location: URL
    }
    
    struct URLs: Codable {
        let full: URL
        let regular: URL
        let small: URL
    }
}
