//
//  PreviewCoreDataWrapper.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-07-23.
//

import SwiftUI
import CoreData

struct PreviewCoreDataWrapper<Content: View>: View {
  let content: (NSManagedObjectContext) -> Content

  var body: some View {
    let managedObjectContext = DataProvider.shared.container.viewContext

    let eventA = (
        name: "My Birthday",
        start: Date(),
        end: Date(timeIntervalSinceNow: 86400),
        emoji: "🎉",
        image: mockImageA
    )
    
    DataProvider.shared.addEvent(to: managedObjectContext, configuration: eventA)
    
    return self.content(managedObjectContext)
  }

  init(@ViewBuilder content: @escaping (NSManagedObjectContext) -> Content) {
    self.content = content
  }
}
