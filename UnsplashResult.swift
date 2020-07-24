//
//  UnsplashResult.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-07-23.
//

import Foundation
import SwiftUI

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
    public let username: String
    public let links: [String : URL]
}

public class UnsplashImage: NSObject, Identifiable, Codable {
    enum Size: String {
        case full, regular, small
    }
    
    public let id: String
    public let color: String
    public let urls: [String : URL]
    public let user: UnsplashUser
}

public struct UnsplashResult: Codable {
    public let results: [UnsplashImage]
}

extension Event {
    func imageURL(size: UnsplashImage.Size) -> URL {
        return (image as! UnsplashImage).urls[size.rawValue]!
    }
    
    var imageColor: Color {
        let image = self.image as! UnsplashImage
        return try! Color(hex: image.color)
    }
    
    var isOver: Bool {
        end! <= Date()
    }
    
    var isUpcoming: Bool {
        !isOver
    }
}

// MARK: ValueTransformer

public typealias Transformable = AnyObject & Codable

public class Transformer<T: Transformable>: ValueTransformer {
    public override class func transformedValueClass() -> AnyClass {
        return T.self
    }
    
    public override class func allowsReverseTransformation() -> Bool {
        return true
    }
    
    public override func transformedValue(_ value: Any?) -> Any? {
        guard let image = value as? T else {
            return nil
        }
        
        return try! JSONEncoder().encode(image)
    }
    
    public override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? NSData else {
            return nil
        }
        
        return try! JSONDecoder().decode(T.self, from: Data(data))
    }
}

@objc(UnsplashImageValueTransformer)
public final class UnsplashImageValueTransformer: Transformer<UnsplashImage> {
    public static func register() {
        let transformer = UnsplashImageValueTransformer()
        let name = NSValueTransformerName(rawValue: String(describing: UnsplashImageValueTransformer.self))
        ValueTransformer.setValueTransformer(transformer, forName: name)
    }
}
