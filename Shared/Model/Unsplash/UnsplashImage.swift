//
//  UnsplashImage.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-08-15.
//

import Foundation

struct UnsplashImage: Identifiable, Codable {
    struct User: Codable {
        let name: String
        let links: [String : URL]
    }
    
    let id: String
    let color: String
    let links: [String : URL]
    let urls: [String : URL]
    let user: User
}

extension BackgroundImage {
    init(localImage data: Data) {
        self.id = UUID().uuidString
        self.downloadEndpoint = nil
        self.color = 0xFFFFFF
        self.user = nil
        
        let url = try! FileManager.default.saveImage(at: id, with: data)
        
        print(url.absoluteString)
        
        self.urls = Dictionary(uniqueKeysWithValues: Size.allCases.map { ($0.rawValue, url) })
    }
    
    init(remoteImage image: UnsplashImage) {
        self.id = image.id
        self.color = Int(hexString: image.color)!
        self.downloadEndpoint = image.links["download_endpoint"]
        self.urls = image.urls
        self.user = Author(name: image.user.name, url: image.user.links["html"]!)
    }
}
