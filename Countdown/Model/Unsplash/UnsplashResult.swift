//
//  UnsplashResult.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-07-23.
//

import Foundation
import SwiftUI

// MARK: Model

public struct UnsplashUser: Codable {
    public let name: String
    public let links: [String : URL]
}

public class UnsplashImage: NSObject, Identifiable, Codable {
    enum Size: String {
        case full, regular, small
    }
    
    private let urls: [String : URL]
    private let color: String

    public let id: String
    public var links: [String : URL]? = nil
    public let user: UnsplashUser
    
    public var overallColor: Color {
        try! Color(hex: color)
    }
    
    func url(for size: UnsplashImage.Size) -> URL {
        self.urls[size.rawValue]!
    }
}

public struct UnsplashResult: Codable {
    public let images: [UnsplashImage]
    
    enum CodingKeys: String, CodingKey {
        case images = "results"
    }
    
    public static var `default`: UnsplashResult {
        let path = Bundle.main.path(forResource: "defaultImages", ofType: "json")
        let json = try! String(contentsOfFile: path!)
        let result = try! JSONDecoder().decode(UnsplashResult.self, from: json.data(using: .utf8)!)
        return result
    }
}
