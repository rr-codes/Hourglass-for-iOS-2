//
//  UnsplashFetchers.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-07-29.
//

import Foundation

public enum FetchError: Error {
    case dataUnavailable(response: URLResponse?)
    case invalidURL(String)
    case invalidQuery(String)
}

public class UnsplashResultProvider {
    public static let shared = UnsplashResultProvider(
        using: .shared,
        authToken: Bundle.main.apiKey(named: "API_KEY")
    )
    
    private static let endpoint = "https://api.unsplash.com/search/photos"
    
    private let clientID: String
    private let urlSession: URLSession
    
    init(using session: URLSession, authToken clientID: String) {
        self.urlSession = session
        self.clientID = clientID
    }
    
    public func fetch(query: String, _ completion: @escaping (Result<UnsplashResult, Error>) -> Void) {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.unsplash.com"
        urlComponents.path = "/search/photos"
        urlComponents.queryItems = [
            URLQueryItem(name: "query", value: query)
        ]
        
        guard let url = urlComponents.url else {
            return completion(.failure(FetchError.invalidURL(urlComponents.description)))
        }

        
        var request = URLRequest(url: url)
        request.addValue("v1", forHTTPHeaderField: "Accept-Version")
        request.setValue("Client-ID \(self.clientID)", forHTTPHeaderField: "Authorization")
        
        self.urlSession.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                return completion(.failure(error ?? FetchError.dataUnavailable(response: response)))
            }
            
            let decoder = JSONDecoder()
            completion(Result {
                try decoder.decode(UnsplashResult.self, from: data)
            })
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
