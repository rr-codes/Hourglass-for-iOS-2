//
//  CountdownApp.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-07-23.
//

import SwiftUI
import WatchConnectivity
import WidgetKit

class MyWCSessionDelegate: NSObject, WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
    }
}

@main
struct CountdownApp: App {
    private let store = PersistenceController.shared
    private let wcDelegate = MyWCSessionDelegate()

    var body: some Scene {
        WindowGroup {
            ContentView(eventManager: .shared)
                .environment(\.managedObjectContext, store.container.viewContext)
                .onAppear {
                    if WCSession.isSupported() {
                        let session = WCSession.default
                        session.delegate = wcDelegate
                        session.activate()
                    }
                }
        }
    }
}
