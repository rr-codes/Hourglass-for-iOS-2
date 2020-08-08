//
//  ColorExtensions.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-08-07.
//

import Foundation
import SwiftUI

extension Color {
    static let secondaryBackground: Self = .init(.secondarySystemBackground)
}

extension Color {
    enum ParseError: Error {
        case invalidHexCode
    }
    
    public init(hex: String) throws {
        let hexColor = String(hex.dropFirst())
        let scanner = Scanner(string: hexColor)
        var hexNumber: UInt64 = 0

        if scanner.scanHexInt64(&hexNumber) {
            let r = Double((hexNumber & 0xFF0000) >> 16) / 255.0
            let g = Double((hexNumber & 0x00FF00) >> 8) / 255.0
            let b = Double((hexNumber & 0x0000FF) >> 0) / 255.0

            self.init(red: r, green: g, blue: b)
            return
        }

        throw ParseError.invalidHexCode
    }
}
