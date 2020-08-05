//
//  CountdownApp.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-07-23.
//

import SwiftUI

@main
struct CountdownApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var store = CoreDataStore.shared
    
    var timer: Timer.TimerPublisher {
        Timer.publish(every: 1.0, on: .main, in: .common)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, store.context)
                .environmentObject(GlobalTimer(from: timer))
        }
        .onChange(of: scenePhase) { phase in
            if phase == .background {
                print("~> background")
                store.save()
            }
        }
    }
}
