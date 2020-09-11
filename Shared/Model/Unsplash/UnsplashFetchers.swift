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
    case dataTaskFailure
}

public class UnsplashResultProvider {
    private let clientID: String
    private let urlSession: URLSession
    private let locale: Locale
    
    init(
        using session: URLSession = .shared,
        authToken clientID: String = Bundle.main.apiKey(named: "Unsplash-API-Key"),
        in locale: Locale = .current
    ) {
        self.clientID = clientID
        self.urlSession = session
        self.locale = locale
    }
    
    private func configureRequest(_ request: inout URLRequest) {
        request.addValue("v1", forHTTPHeaderField: "Accept-Version")
        request.setValue("Client-ID \(self.clientID)", forHTTPHeaderField: "Authorization")
    }
    
    func sendDownloadRequest(for image: BackgroundImage) {
        guard let url = image.downloadEndpoint else {
            return
        }
        var request = URLRequest(url: url)
        self.configureRequest(&request)
    
        self.urlSession.dataTask(with: request).resume()
    }
    
    private func createURLComponents(query: String, numberOfResults: Int) -> URLComponents {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.unsplash.com"
        urlComponents.path = "/search/photos"
        urlComponents.queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "per_page", value: "\(numberOfResults)")
        ]
        
        if let languageCode = locale.languageCode {
            let query = URLQueryItem(name: "lang", value: languageCode)
            urlComponents.queryItems?.append(query)
        }
        
        return urlComponents
    }
    
    /// Fetches images from Unsplash using the specified `query` into an `UnsplashResult` and publishes the result to the `result` field
    public func fetch(query: String, numberOfResults: Int, _ completion: @escaping (Result<UnsplashResult, Error>) -> Void) {
        let urlComponents = createURLComponents(query: query, numberOfResults: numberOfResults)
        
        guard let url = urlComponents.url else {
            completion(.failure(FetchError.invalidURL(urlComponents.description)))
            return
        }
        
        var request = URLRequest(url: url)
        self.configureRequest(&request)
        
        self.urlSession.dataTask(with: request) { (data, _, error) in
            guard let data = data, error == nil else {
                completion(.failure(error ?? FetchError.dataTaskFailure))
                return
            }
            
            let result = Result {
                try JSONDecoder().decode(UnsplashResult.self, from: data)
            }
            
            completion(result)
        }.resume()
    }
}
