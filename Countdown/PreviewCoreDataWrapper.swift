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
        end: Date(timeIntervalSinceNow: 86400 - 60),
        emoji: "😍",
        image: MockImages.birthday
    )
    
    let eventB = (
        name: "New Year's Day",
        start: Date(),
        end: Date(timeIntervalSinceNow: 86400 * 42),
        emoji: "🎉",
        image: MockImages.fireworks
    )
    
    let eventC = (
        name: "Christmas",
        start: Date(),
        end: Date(timeIntervalSinceNow: 86400 * 300),
        emoji: "🎄",
        image: MockImages.christmas
    )
    
    let eventD = (
        name: "My Anniversary",
        start: Date(),
        end: Date(timeIntervalSinceNow: -60 * 70),
        emoji: "💍",
        image: MockImages.anniversary
    )
    
    for event in [eventA, eventB, eventC, eventD] {
        DataProvider.shared.addEvent(to: managedObjectContext, configuration: event)
    }
    
    return self.content(managedObjectContext)
  }

  init(@ViewBuilder content: @escaping (NSManagedObjectContext) -> Content) {
    self.content = content
  }
}
