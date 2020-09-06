//
//  CountdownApp.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-07-23.
//

import SwiftUI
import Sentry
import WatchConnectivity

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
    
    var sentryKey: String {
        Bundle.main.apiKey(named: "Sentry-Key")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(eventManager: .shared)
                .environment(\.managedObjectContext, store.container.viewContext)
                .onAppear {
                    SentrySDK.start { options in
                        options.dsn = "https://\(sentryKey)@o432249.ingest.sentry.io/5384677"
                        options.debug = true // Enabled debug when first installing is always helpful
                    }
                    
                    if WCSession.isSupported() {
                        let session = WCSession.default
                        session.delegate = wcDelegate
                        session.activate()
                    }
                }
        }
    }
}
