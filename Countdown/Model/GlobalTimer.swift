//
//  GlobalTimer.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-08-04.
//

import Foundation

public class GlobalTimer: ObservableObject {
    @Published public var lastUpdated = Date()
            
    public init(from publisher: Timer.TimerPublisher) {
        publisher.autoconnect().assign(to: &$lastUpdated)
    }
}
