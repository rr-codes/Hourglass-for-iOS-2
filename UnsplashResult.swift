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
    public let username: String
    public let links: [String : URL]
}

public class UnsplashImage: NSObject, Identifiable, Codable {
    enum Size: String {
        case full, regular, small
    }
    
    private let urls: [String : URL]
    private let color: String

    public let id: String
    public let user: UnsplashUser
    
    public var overallColor: Color {
        return try! Color(hex: color)
    }
    
    func url(for size: UnsplashImage.Size) -> URL {
        return self.urls[size.rawValue]!
    }
}

public struct UnsplashResult: Codable {
    public enum FetchError: Error {
        case dataUnavailable
    }
    
    public let results: [UnsplashImage]
    
    public func fetch(query: String, _ completion: @escaping (Result<UnsplashResult, Error>) -> Void) {
        let clientID = Bundle.main.apiKey(named: "API_KEY")
        let endpoint = "https://api.unsplash.com/search/photos"
        
        let url = URL(string: "\(endpoint)?query=\(query)")
        var request = URLRequest(url: url!)
        request.addValue("v1", forHTTPHeaderField: "Accept-Version")
        request.setValue("Client-ID \(clientID)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                completion(.failure(error ?? FetchError.dataUnavailable))
                return
            }
            
            do {
                let result = try JSONDecoder().decode(Self.self, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }.resume()
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
