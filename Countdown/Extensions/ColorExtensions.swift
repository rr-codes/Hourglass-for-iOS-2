//
//  ColorExtensions.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-08-07.
//

import Foundation
import SwiftUI

extension Color {
    static let background: Self = .init(.systemBackground)
    static let foreground: Self = .init(.label)
    static let tertiaryBackground: Self = Color(.secondarySystemBackground).opacity(0.5)
    static let secondaryBackground: Self = .init(.secondarySystemBackground)
}

extension Int {
    init?(hexString: String) {
        let scanner = Scanner(string: hexString.replacingOccurrences(of: "#", with: ""))
        var hexNumber: UInt64 = 0

        if scanner.scanHexInt64(&hexNumber) {
            self.init(hexNumber)
        } else {
            return nil
        }
    }
}

extension Color {
    init(code: Int) {
        let r = Double((code & 0xFF0000) >> 16) / 255.0
        let g = Double((code & 0x00FF00) >> 8) / 255.0
        let b = Double((code & 0x0000FF) >> 0) / 255.0
        
        self.init(red: r, green: g, blue: b)
    }
}
