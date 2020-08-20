//
//  UnsplashImage.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-08-15.
//

import Foundation
import SwiftUI

public struct UnsplashUser: Codable {
    public let name: String
    public let links: [String : URL]
}

public class UnsplashImage: NSObject, Identifiable, Codable {
    enum Size: String {
        case full, regular, small
    }
    
    private let urls: [String : URL]
    private let color: String

    public let id: String
    public var links: [String : URL]? = nil
    public let user: UnsplashUser
    
    public var overallColor: Color {
        try! Color(hex: color)
    }
    
    func url(for size: UnsplashImage.Size) -> URL {
        self.urls[size.rawValue]!
    }
}
