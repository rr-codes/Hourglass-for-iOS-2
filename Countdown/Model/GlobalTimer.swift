//
//  GlobalTimer.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-08-04.
//

import Foundation
import Combine
import SwiftUI

class PublishedObservable<P: Publisher>: ObservableObject {
    @Published private(set) var output: P.Output
        
    fileprivate init(wrapping publisher: P, initialValue: () -> P.Output) where P.Failure == Never {
        self.output = initialValue()
        publisher.assign(to: &$output)
    }
}

extension Publisher {
    func observable(initialValue: @autoclosure () -> Output) -> PublishedObservable<Self> where Failure == Never {
        PublishedObservable(wrapping: self, initialValue: initialValue)
    }
}

typealias ObservableTimer = PublishedObservable<Publishers.Autoconnect<Timer.TimerPublisher>>

extension ObservableTimer {
    static let shared: ObservableTimer = Timer.publish(every: 1.0, on: .main, in: .common)
        .autoconnect()
        .observable(initialValue: Date())
}
