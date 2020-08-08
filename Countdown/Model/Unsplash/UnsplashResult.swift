//
//  UnsplashResult.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-07-23.
//

import Foundation
import SwiftUI

extension Bundle {
    func apiKey(named keyName: String) -> String {
        let path = self.path(forResource: "ApiKeys", ofType: "plist")
        let plist = NSDictionary(contentsOfFile: path!)
        return plist!.object(forKey: keyName) as! String
    }
}

extension Color {
    enum ParseError: Error {
        case invalidHexCode
    }
    
    public init(hex: String) throws {
        let hexColor = String(hex.dropFirst())
        let scanner = Scanner(string: hexColor)
        var hexNumber: UInt64 = 0

        if scanner.scanHexInt64(&hexNumber) {
            let r = Double((hexNumber & 0xFF0000) >> 16) / 255.0
            let g = Double((hexNumber & 0x00FF00) >> 8) / 255.0
            let b = Double((hexNumber & 0x0000FF) >> 0) / 255.0

            self.init(red: r, green: g, blue: b)
            return
        }

        throw ParseError.invalidHexCode
    }
}

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
    
    static func ==(lhs: UnsplashImage, rhs: UnsplashImage) -> Bool {
        lhs.id == rhs.id
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
