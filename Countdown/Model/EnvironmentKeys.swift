//
//  EnvironmentKeys.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-08-01.
//

import Foundation
import SwiftUI

struct CalendarKey: EnvironmentKey {
    static let defaultValue: Calendar = .current
}

struct EmojiProviderKey: EnvironmentKey {
    static let defaultValue: EmojiDBProvider = .shared
}

struct EventManagerKey: EnvironmentKey {
    static let defaultValue: EventManager = .shared
}

extension EnvironmentValues {
    var calendar: Calendar {
        get { self[CalendarKey.self] }
        set { self[CalendarKey.self] = newValue }
    }
    
    var emojiProvider: EmojiDBProvider {
        get { self[EmojiProviderKey.self] }
        set { self[EmojiProviderKey.self] = newValue }
    }
    
    var eventManager: EventManager {
        get { self[EventManagerKey.self] }
        set { self[EventManagerKey.self] = newValue }
    }
}
