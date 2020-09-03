//
//  EmojiModel.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-07-31.
//

import Foundation
import Combine

struct EmojiCategory: Codable, Identifiable, Hashable {
    var id: String { emoji }
    
    let emoji: String
    let name: String
    let elements: [String]
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
