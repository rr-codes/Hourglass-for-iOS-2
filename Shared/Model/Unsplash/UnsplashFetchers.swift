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
    @Published public var result: UnsplashResult? = nil
    
    private let clientID: String
    private let urlSession: URLSession
    private let runLoop: RunLoop
    private let locale: Locale
    
    init(
        using session: URLSession = .shared,
        authToken clientID: String = Bundle.main.apiKey(named: "Unsplash-API-Key"),
        on runLoop: RunLoop = .main,
        in locale: Locale = .current
    ) {
        self.clientID = clientID
        self.urlSession = session
        self.runLoop = runLoop
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
    
    /// Fetches images from Unsplash using the specified `query` into an `UnsplashResult` and publishes the result to the `result` field
    public func fetch(query: String) throws {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.unsplash.com"
        urlComponents.path = "/search/photos"
        urlComponents.queryItems = [
            URLQueryItem(name: "query", value: query),
        ]
        
        if let languageCode = locale.languageCode {
            let query = URLQueryItem(name: "lang", value: languageCode)
            urlComponents.queryItems?.append(query)
        }
        
        guard let url = urlComponents.url else {
            throw FetchError.invalidURL(urlComponents.description)
        }
        
        var request = URLRequest(url: url)
        self.configureRequest(&request)
        
        self.urlSession.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: UnsplashResult?.self, decoder: JSONDecoder())
            .replaceError(with: nil)
            .receive(on: runLoop)
            .assign(to: &$result)
    }
}
