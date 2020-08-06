//
//  GlobalTimer.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-08-04.
//

import Foundation
import Combine

public class GlobalTimer: ObservableObject {
    @Published public var lastUpdated = Date()
    
    private let _isActive = CurrentValueSubject<Bool, Never>(true)
    
    public var isActive: Bool {
        get { _isActive.value }
        set { _isActive.send(newValue) }
    }
            
    public init(from publisher: Timer.TimerPublisher) {        
        self._isActive
            .combineLatest(publisher.autoconnect())
            .filter(\.0)
            .map(\.1)
            .assign(to: &$lastUpdated)
    }
}
