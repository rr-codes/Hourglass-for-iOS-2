//
//  Event.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-08-05.
//

import Foundation
import CoreData

enum ImageSize: String {
    case small, regular, full
}

struct ImageAuthor: Codable {
    let name: String
    private let links: [String : URL]
    
    var profile: URL {
        links["html"]!
    }
    
    init(name: String, profile: URL) {
        self.name = name
        self.links = ["html" : profile]
    }
}

protocol EventImage {
    var id: String { get }
    
    var downloadEndpoint: URL? { get }

    var color: Int { get }
    
    var user: ImageAuthor? { get }
        
    func url(for size: ImageSize) -> URL
}


struct UnsplashImage: EventImage, Decodable {
    let id: String
    let user: ImageAuthor?
    
    private let rawColor: String
    private let links: [String : URL]
    private let urls: [String : URL]
    
    var color: Int {
        Int(hexString: rawColor) ?? 0xFFFFFF
    }
    
    var downloadEndpoint: URL? {
        links["download_location"]!
    }
    
    func url(for size: ImageSize) -> URL {
        urls[size.rawValue]!
    }
}

extension UnsplashImage {
    init(id: String, rawColor: String, downloadEndpoint: URL, urls: [String : URL], author: String, authorProfile: URL) {
        self.id = id
        self.rawColor = rawColor
        self.links = ["download_location" : downloadEndpoint]
        self.urls = urls
        self.user = .init(name: author, profile: authorProfile)
    }
}

struct LocalImage: EventImage {
    let user: ImageAuthor? = nil
        
    let downloadEndpoint: URL? = nil
    
    let color: Int = 0xFFFFFF
    
    let id: String
    
    private let url: URL
    
    /// Use when fetching `LocalImage`s from CoreData
    init(from localURL: URL, id: String) {
        self.id = id
        self.url = localURL
    }
    
    /// Use when creating a `LocalImage`
    init(from data: Data) {
        self.id = UUID().uuidString
        self.url = try! FileManager.default.saveImage(at: id, with: data)
    }
    
    func url(for size: ImageSize) -> URL {
        url
    }
}

struct Event: Identifiable, Equatable {
    let id: UUID
    
    let name: String
    let start: Date
    let end: Date
    let emoji: String
    
    let image: EventImage
    
    static func == (lhs: Event, rhs: Event) -> Bool {
        lhs.id == rhs.id
    }
}

extension Event {
    static func bridged(from entity: EventMO) -> Event? {
        guard let name = entity.name,
              let start = entity.start,
              let end = entity.end,
              let emoji = entity.emoji,
              let resource = entity.resources
        else {
            return nil
        }
        
        let image: EventImage
        
        switch resource {
        case let resource as LocalImageResourceMO:
            let url = resource.sources!.full!
            let id = UUID()
            
            image = LocalImage(from: url, id: id.uuidString)
            
        case let resource as UnsplashImageMO:
            let rawColor = resource.rawColor
            let urls = [
                "full" : resource.sources!.full!,
                "regular" : resource.sources!.regular!,
                "small" : resource.sources!.small!
            ]
                        
            let downloadEndpoint = resource.downloadEndpoint!
            
            image = UnsplashImage(
                id: UUID().uuidString,
                rawColor: String(format:"#%06X", rawColor),
                downloadEndpoint: downloadEndpoint,
                urls: urls,
                author: resource.author!,
                authorProfile: resource.authorProfile!
            )
            
        default:
            fatalError()
        }
        
        return Event(id: UUID(), name: name, start: start, end: end, emoji: emoji, image: image)
    }
}

//struct ImageSources: Decodable {
//    let full: URL
//    let regular: URL
//    let small: URL
//
//    init(from url: URL) {
//        self.init(full: url, regular: url, small: url)
//    }
//
//    init(full: URL, regular: URL, small: URL) {
//        self.full = full
//        self.regular = regular
//        self.small = small
//    }
//
//    init?(bridgedFrom sources: ImageSourcesMO) {
//        guard let full = sources.full,
//              let regular = sources.regular,
//              let small = sources.small
//        else {
//            return nil
//        }
//
//        self.init(full: full, regular: regular, small: small)
//    }
//}
//
//extension ImageSourcesMO {
//    convenience init(bridgedFrom sources: ImageSources, context: NSManagedObjectContext) {
//        self.init(context: context)
//
//        self.full = sources.full
//        self.regular = sources.regular
//        self.small = sources.small
//    }
//}
//
//protocol ImageResource: Identifiable {
//    var sources: ImageSources { get }
//    var colorHexCode: Int { get }
//}
//
//protocol RemoteImageResource: ImageResource {
//}
//
//struct LocalImageResource: ImageResource {
//    let id = UUID()
//    let sources: ImageSources
//    let colorHexCode: Int
//
//    init(from data: Data) {
//        let url = try! FileManager.default.saveImage(at: id.uuidString, with: data)
//
//        self.sources = .init(from: url)
//        self.colorHexCode = 0xFFFFFF
//    }
//
//    init?(bridgedFrom resource: LocalImageResourceMO) {
//        guard let sources = resource.sources,
//              let bridged = ImageSources(bridgedFrom: sources)
//        else {
//            return nil
//        }
//
//        self.sources = bridged
//        self.colorHexCode = Int(resource.rawColor)
//    }
//}
//
//extension LocalImageResourceMO {
//    convenience init(bridgedFrom resource: LocalImageResource, context: NSManagedObjectContext) {
//        self.init(context: context)
//
//        self.sources = ImageSourcesMO(bridgedFrom: resource.sources, context: context)
//        self.rawColor = Int16(resource.colorHexCode)
//    }
//}
//
//struct UnsplashImage: RemoteImageResource {
//    let id = UUID()
//    let sources: ImageSources
//    let colorHexCode: Int
//
//    let author: String
//    let downloadEndpoint: URL
//    let authorProfile: URL
//
//    init?(bridgedFrom image: UnsplashImageMO) {
//        guard let sources = image.sources,
//              let bridged = ImageSources(bridgedFrom: sources),
//              let author = image.author,
//              let downloadEndpoint = image.downloadEndpoint,
//              let authorProfile = image.authorProfile
//        else {
//            return nil
//        }
//
//        self.sources = bridged
//        self.colorHexCode = Int(image.rawColor)
//
//        self.author = author
//        self.downloadEndpoint = downloadEndpoint
//        self.authorProfile = authorProfile
//    }
//}
//
///// ```json
///// {
/////     "id": "-Qf9JKLysUg",
/////     "color": "#FEE5D6",
/////     "links": {
/////         "download_location": "https://api.unsplash.com/photos/Xaanw0s0pMk/download"
/////     },
/////     "urls": {
/////         "full": "https://images.unsplash.com/photo-1512474932049-78ac69ede12c?ixlib=rb-1.2.1&q=85&fm=jpg&crop=entropy&cs=srgb&ixid=eyJhcHBfaWQiOjE1MDY2Mn0",
/////         "regular": "https://images.unsplash.com/photo-1512474932049-78ac69ede12c?ixlib=rb-1.2.1&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=1080&fit=max&ixid=eyJhcHBfaWQiOjE1MDY2Mn0",
/////         "small": "https://images.unsplash.com/photo-1512474932049-78ac69ede12c?ixlib=rb-1.2.1&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=400&fit=max&ixid=eyJhcHBfaWQiOjE1MDY2Mn0"
/////     },
/////     "user": {
/////         "name": "freestocks",
/////         "links": {
/////             "html": "https://unsplash.com/@freestocks"
/////         }
/////     }
///// }
///// ```
//extension UnsplashImage: Decodable {
//    enum CodingKeys: String, CodingKey {
//        case color
//        case urls
//        case user
//        case links
//    }
//
//    enum UserCodingKeys: String, CodingKey {
//        case name
//        case links
//    }
//
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//
//        let colorString = try container.decode(String.self, forKey: .color)
//        let urls = try container.decode([String : URL].self, forKey: .urls)
//        let links = try container.decode([String : URL].self, forKey: .links)
//
//        let nested = try container.nestedContainer(keyedBy: UserCodingKeys.self, forKey: .user)
//        let name = try nested.decode(String.self, forKey: .name)
//        let userLinks = try nested.decode([String : URL].self, forKey: .links)
//
//        self.sources = ImageSources(full: urls["full"]!, regular: urls["regular"]!, small: urls["small"]!)
//        self.colorHexCode = Int(hexString: colorString) ?? 0xFFFFFF
//
//        self.author = name
//        self.downloadEndpoint = links["download_location"]!
//        self.authorProfile = userLinks["html"]!
//    }
//}
//
//extension UnsplashImageMO {
//    convenience init(bridgedFrom image: UnsplashImage, context: NSManagedObjectContext) {
//        self.init(context: context)
//
//        self.sources = ImageSourcesMO(bridgedFrom: image.sources, context: context)
//        self.rawColor = Int16(image.colorHexCode)
//
//        self.author = image.author
//        self.downloadEndpoint = image.downloadEndpoint
//        self.authorProfile = image.authorProfile
//    }
//}
//
//struct Event<Resource: ImageResource>: Identifiable, Equatable {
//    static func == (lhs: Event<Resource>, rhs: Event<Resource>) -> Bool {
//        lhs.id == rhs.id
//    }
//
//    let id = UUID()
//
//    let name: String
//    let start: Date
//    let end: Date
//    let imageResource: Resource
//    let emoji: String
//
//    var isOver: Bool {
//        end < Date()
//    }
//
//    init(_ name: String, end: Date, image: Resource, emoji: String, start: Date = Date()) {
//        self.name = name
//        self.start = start
//        self.end = end
//        self.imageResource = image
//        self.emoji = emoji
//    }
//
//    init?(bridged event: EventMO) {
//        guard let name = event.name,
//              let end = event.end,
//              let resource = event.resources,
//              let emoji = event.emoji,
//              let start = event.start
//        else { return nil}
//
//        /// i have no idea what to do from here on out
//
//        if let resource = resource as? LocalImageResourceMO {
//            let bridged = LocalImageResource(bridgedFrom: resource)
//        } else if let resource = resource as? RemoteImageResourceMO {
//            if let unsplash = resource as? UnsplashImageMO {
//                let bridged = UnsplashImage(bridgedFrom: unsplash)
//            }
//        }
//    }
//}

//struct Event: Identifiable, Equatable {
//    static func == (lhs: Event, rhs: Event) -> Bool {
//        lhs.id == rhs.id
//    }
//
//    let id: NSManagedObjectID
//    let name: String
//    let start: Date
//    let end: Date
//    let image: ImageResourceMO
//    let emoji: String
//
//    var isOver: Bool {
//        end < Date()
//    }
//
//    init(_ name: String, end: Date, image: ImageResourceMO, emoji: String, start: Date = Date()) {
//        self.name = name
//        self.start = start
//        self.end = end
//        self.image = image
//        self.emoji = emoji
//    }
//
//    init?(bridged event: EventMO) {
//        guard let name = event.name,
//              let end = event.end,
//              let emoji = event.emoji,
//              let start = event.start
//        else { return nil}
//
////        guard let image = try? JSONDecoder().decode(RemoteImage.self, from: imageData) else {
//            return nil
////        }
//
////        self.init(name, end: end, image: image, emoji: emoji, start: start, id: id)
//    }
//}
//
//extension EventMO {
//    convenience init(bridged event: Event, context: NSManagedObjectContext) {
//        self.init(context: context)
//
//        self.name = event.name
//        self.start = event.start
//        self.end = event.end
//        self.emoji = event.emoji
////        self.image = try? JSONEncoder().encode(event.image)
//    }
//
//    func imageResource(for size: ImageResourceMO.Size) -> ImageResourceMO? {
//        return resources?
//            .compactMap { $0 as? ImageResourceMO }
//            .first { $0.size == size }
//    }
//}
//
//
//extension ImageResourceMO {
//    enum Size: Int16 {
//        case small, regular, large
//    }
//
//    var colorCode: Int {
//        rawColor.flatMap { Int(hexString: $0) } ?? 0xFFFFFF
//    }
//
//    var size: Size {
//        Size(rawValue: rawSizeClass)!
//    }
//}
