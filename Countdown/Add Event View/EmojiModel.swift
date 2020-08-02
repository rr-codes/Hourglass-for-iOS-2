//
//  EmojiModel.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-07-31.
//

import Foundation

struct Emoji: Decodable, Identifiable {
    var id: String {
        emoji
    }
    
    let name: String
    let emoji: String
}

class EmojiDBProvider {
    typealias Database = [[Emoji]]
    
    struct Category: Identifiable {
        let id: Int
        let name: String
        let emoji: String
    }
    
    static let shared = EmojiDBProvider(
        from: try! String(contentsOfFile: Bundle.main.path(forResource: "emoji", ofType: "json")!)
    )
    
    static let categories: [Category] = [
        Category(id: 0, name: "Smileys",         emoji: "😀"),
        Category(id: 1, name: "Travel & Places", emoji: "🌍"),
        Category(id: 2, name: "Activities",      emoji: "🎉"),
        Category(id: 3, name: "Objects",         emoji: "👔"),
        Category(id: 4, name: "Flags",           emoji: "🏁"),
    ]
    
    private let contents: Data
    
    lazy var database: Database = {
        try! JSONDecoder().decode(Database.self, from: contents)
    }()
    
    init(from contents: String) {
        self.contents = contents.data(using: .utf8)!
    }
}
