//
//  UnsplashResult.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-07-23.
//

import Foundation
import SwiftUI

// MARK: Model

public struct UnsplashResult: Decodable, Equatable {
    let images: [UnsplashImage]
    
    enum CodingKeys: String, CodingKey {
        case images = "results"
    }
    
    public static var `default`: UnsplashResult {
        let path = Bundle.main.path(forResource: "defaultImages", ofType: "json")
        let json = try! String(contentsOfFile: path!)
        let result = try! JSONDecoder().decode(UnsplashResult.self, from: json.data(using: .utf8)!)
        return result
    }
}
