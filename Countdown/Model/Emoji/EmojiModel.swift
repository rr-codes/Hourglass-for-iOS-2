//
//  EmojiModel.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-07-31.
//

import Foundation
import Combine

struct Emoji: Codable, Identifiable, Hashable, CustomStringConvertible {
    var description: String { name }
    var id: String { emoji }
    
    let name: String
    var emoji: String
}

struct EmojiCategory: Codable, Identifiable, Hashable {
    var id: String { emoji }
    
    let name: String
    let emoji: String
    let all: [Emoji]
}

typealias EmojiDatabase = [EmojiCategory]

class EmojiProvider: ObservableObject {
    static let shared: EmojiProvider = {
        let data = Bundle.main.data(forResource: "emoji", ofType: "json", using: .utf8)
        return try! EmojiProvider(from: data!)
    }()
    
    let database: EmojiDatabase
    
    init(from data: Data) throws {
        let decoded = try JSONDecoder().decode(EmojiDatabase.self, from: data)
        self.database = decoded
    }
}

extension EmojiDatabase: Database {
    var all: [Emoji] {
        self.flatMap(\.all)
    }
    
    var limit: Int {
        return 20
    }
}
