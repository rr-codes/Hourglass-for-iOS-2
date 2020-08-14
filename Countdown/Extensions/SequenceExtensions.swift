//
//  SequenceExtensions.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-08-11.
//

import Foundation

extension Sequence {
    /// Alias for `Sequence/contains(where:)`
    static func ~=(lhs: Self, rhs: (Self.Element) throws -> Bool) rethrows -> Bool {
        try lhs.contains(where: rhs)
    }
}

extension Sequence where Element: Equatable {
    /// Alias for `Sequence/contains(_:)`
    static func ~=(lhs: Self, rhs: Self.Element) -> Bool {
        lhs.contains(rhs)
    }
}
