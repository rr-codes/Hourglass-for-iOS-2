//
//  GlobalTimer.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-08-04.
//

import Foundation
import Combine
import SwiftUI

class ObservablePublisher<P: Publisher>: ObservableObject where P.Failure == Never {
    @Published private(set) var output: P.Output
        
    fileprivate init(wrapping publisher: P, initialValue: P.Output) {
        self.output = initialValue
        publisher.assign(to: &$output)
    }
}

extension Publisher where Failure == Never {
    func observable(initialValue: Output) -> ObservablePublisher<Self> {
        ObservablePublisher(wrapping: self, initialValue: initialValue)
    }
}

// MARK: Timer

typealias ObservableTimer = ObservablePublisher<Publishers.Autoconnect<Timer.TimerPublisher>>

#if DEBUG
extension ObservableTimer {
    static let shared = Timer.publish(every: 1.0, on: .main, in: .common)
        .autoconnect()
        .observable(initialValue: Date())
}
#endif
