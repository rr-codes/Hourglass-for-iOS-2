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
    @StateObject private var store = DataProvider.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, store.context)
        }
        .onChange(of: scenePhase) { phase in
            if phase == .background {
                print("~> background")
                store.save()
            }
        }
    }
}
