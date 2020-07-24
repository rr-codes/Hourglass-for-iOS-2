//
//  CountdownApp.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-07-23.
//

import SwiftUI

@main
struct CountdownApp: App {
    static let container = DataProvider.shared.container
    
    var body: some Scene {
        WindowGroup {
            ContentView().environment(\.managedObjectContext, Self.container.viewContext)
        }
    }
}
