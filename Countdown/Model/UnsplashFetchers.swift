//
//  UnsplashFetchers.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-07-29.
//

import Foundation
import Combine
import SwiftUI

public enum FetchError: Error {
    case invalidURL(String)
}

public class UnsplashResultProvider: ObservableObject {
    public static let shared = UnsplashResultProvider(
        using: .shared,
        authToken: Bundle.main.apiKey(named: "API_KEY"),
        on: .main
    )
        
    @Published public var result: UnsplashResult? = nil
    
    private let clientID: String
    private let urlSession: URLSession
    private let runLoop: RunLoop
    
    init(using session: URLSession, authToken clientID: String, on runLoop: RunLoop) {
        self.urlSession = session
        self.clientID = clientID
        self.runLoop = runLoop
    }
    
    public func sendDownloadRequest(for image: UnsplashImage) {
        guard let url = image.links?["download_location"] else {
            return
        }
        
        var request = URLRequest(url: url)
        request.addValue("v1", forHTTPHeaderField: "Accept-Version")
        request.setValue("Client-ID \(self.clientID)", forHTTPHeaderField: "Authorization")
        
        self.urlSession.dataTask(with: request) { (_, _, error) in
            if let error = error {
                fatalError(error.localizedDescription)
            }
        }.resume()
    }
    
    /// Fetches images from Unsplash using the specified `query` into an `UnsplashResult` and publishes the result to the `result` field
    public func fetch(query: String) throws {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.unsplash.com"
        urlComponents.path = "/search/photos"
        urlComponents.queryItems = [
            URLQueryItem(name: "query", value: query)
        ]
        
        guard let url = urlComponents.url else {
            throw FetchError.invalidURL(urlComponents.description)
        }
        
        var request = URLRequest(url: url)
        request.addValue("v1", forHTTPHeaderField: "Accept-Version")
        request.setValue("Client-ID \(self.clientID)", forHTTPHeaderField: "Authorization")
        
        self.urlSession.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: UnsplashResult?.self, decoder: JSONDecoder())
            .replaceError(with: nil)
            .receive(on: runLoop)
            .assign(to: &$result)
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
