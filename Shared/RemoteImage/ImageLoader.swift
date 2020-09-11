//
//  ImageLoader.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-09-10.
//

import Foundation
import SwiftUI
import Combine

class ImageLoader: ObservableObject {
    private static let imageProcessingQueue = DispatchQueue(label: "image-processing")

    @Published var image: UIImage?
    
    private let url: URL
    private let urlSession: URLSession
    
    private var cache: ImageCache?
    private(set) var isLoading = false
        
    init(_ url: URL, using urlSession: URLSession, cache: ImageCache? = nil) {
        self.url = url
        self.urlSession = urlSession
        self.cache = cache
    }
    
    func load() {
        guard !isLoading else {
            return
        }
        
        if let image = cache?[url] {
            self.image = image
            return
        }
        
        self.urlSession
            .dataTaskPublisher(for: url)
            .subscribe(on: Self.imageProcessingQueue)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .handleEvents(
                receiveSubscription: { [weak self] _ in self?.onStart() },
                receiveOutput: { [weak self] in self?.cache($0) },
                receiveCompletion: { [weak self] _ in self?.onFinish() },
                receiveCancel: { [weak self] in self?.onFinish() }
            )
            .receive(on: DispatchQueue.main)
            .assign(to: &$image)
    }
    
    private func onStart() {
        isLoading = true
    }
    
    private func onFinish() {
        isLoading = false
    }
    
    private func cache(_ image: UIImage?) {
        if let image = image {
            cache?[url] = image
            print("caching image \(image)")
        }
    }
}

// MARK: Cache

protocol ImageCache: AnyObject {
    subscript(_ url: URL) -> UIImage? { get set }
}

extension ImageCache {
    func preload(imageURL url: URL, using session: URLSession) {
        session.dataTask(with: url) { [weak self] (data, _, error) in
            guard let data = data, let image = UIImage(data: data), error == nil else {
                print("could not preload image with url \(url)")
                return
            }
            
            if let self = self, self[url] == nil {
                self[url] = image
            }
        }.resume()
    }
}

class TemporaryImageCache: ImageCache {
    private let cache = NSCache<NSURL, UIImage>()
    
    subscript(url: URL) -> UIImage? {
        get { cache.object(forKey: url as NSURL) }
        set {
            if let newValue = newValue {
                cache.setObject(newValue, forKey: url as NSURL)
            } else {
                cache.removeObject(forKey: url as NSURL)
            }
        }
    }
}

// MARK: Environment

struct ImageCacheKey: EnvironmentKey {
    static let defaultValue: ImageCache = TemporaryImageCache()
}

extension EnvironmentValues {
    var imageCache: ImageCache {
        get { self[ImageCacheKey.self] }
        set { self[ImageCacheKey.self] = newValue }
    }
}
