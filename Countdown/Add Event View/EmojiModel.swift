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
    typealias Categories = [(id: Int, name: String, emoji: String)]
    
    static let shared = EmojiDBProvider(
        from: try! String(contentsOfFile: Bundle.main.path(forResource: "emoji", ofType: "json")!)
    )
    
    static let categories: Categories = [
        (0, "Smileys", "😀"),
        (1, "Travel & Places", "🌍"),
        (2, "Activities", "🎉"),
        (3, "Objects", "👔"),
        (4, "Flags", "🏁"),
    ]
    
    private let contents: Data
    
    lazy var database: Database = {
        try! JSONDecoder().decode(Database.self, from: contents)
    }()
    
    init(from contents: String) {
        self.contents = contents.data(using: .utf8)!
    }
}
