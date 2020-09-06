//
//  CountdownApp.swift
//  Watch Extension
//
//  Created by Richard Robinson on 2020-09-04.
//

import SwiftUI
import WatchConnectivity

class MyWCSessionDelegate: NSObject, WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("\(error)")
        }
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        if let gradientIndex = userInfo["gradientIndex"] as? Int {
            UserDefaults.standard.set(gradientIndex, forKey: "gradientIndex")
        }
    }
}

@main
struct CountdownApp: App {
    let persistenceController = PersistenceController.shared
    let wcDelegate = MyWCSessionDelegate()

    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
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
}
