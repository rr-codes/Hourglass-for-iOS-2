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
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var store = CoreDataStore.shared
    
    var timer: Timer.TimerPublisher {
        Timer.publish(every: 1.0, on: .main, in: .common)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(eventManager: .shared)
                .environment(\.managedObjectContext, store.context)
                .onAppear {
                    SentrySDK.start { options in
                        options.dsn = "https://5194002887d04b8eaaaad02d3fcd1d1d@o432249.ingest.sentry.io/5384677"
                        options.debug = true // Enabled debug when first installing is always helpful
                    }
                }
        }
        .onChange(of: scenePhase) { phase in
            if phase == .background {
                print("~> background")
                store.save()
            }
        }
    }
}
