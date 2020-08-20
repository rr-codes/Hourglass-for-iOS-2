//
//  CombineExtensions.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-08-18.
//

import Foundation
import SwiftUI

extension Binding {
    static func ??<T>(binding: Self, defaultValue: @escaping @autoclosure () -> T) -> Binding<T> where Value == Optional<T> {
        .init {
            binding.wrappedValue ?? defaultValue()
        } set: {
            binding.wrappedValue = $0
        }
    }
}
