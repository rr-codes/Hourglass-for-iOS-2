//
//  CountdownApp.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-07-23.
//

import SwiftUI
import Sentry

@main
struct CountdownApp: App {
    @StateObject private var store = CoreDataStore.shared
    
    var sentryKey: String {
        Bundle.main.apiKey(named: "Sentry-Key")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(eventManager: .shared)
                .environment(\.managedObjectContext, store.context)
                .onAppear {
                    SentrySDK.start { options in
                        options.dsn = "https://\(sentryKey)@o432249.ingest.sentry.io/5384677"
                        options.debug = true // Enabled debug when first installing is always helpful
                    }
                }
        }
    }
}
