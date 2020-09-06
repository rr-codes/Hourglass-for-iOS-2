//
//  ContentView.swift
//  Watch Extension
//
//  Created by Richard Robinson on 2020-09-04.
//

import SwiftUI
import CoreData

struct NoEventsView: View {
    let emojiString = ["🥳", "🍭", "🎉"].joined(separator: "  ")
    
    var body: some View {
        VStack {
            Text("🥳  🍭  🎉").font(.title2)
            
            Spacer().height(20)
            
            Text("Create and edit events on your phone")
        }
        .multilineTextAlignment(.center)
    }
}

struct ListCellView: View {
    let name: String
    let emoji: String
    
    var body: some View {
        HStack(spacing: 10) {
            Text(emoji)
            
            Text(name)
        }
    }
}

struct ListView: View {
    let events: [Event]
    
    var footer: some View {
        Text("Create and edit events on your phone").multilineTextAlignment(.center)
    }
    
    var body: some View {
        List {
            Section(footer: footer) {
                ForEach(events) { event in
                    NavigationLink(
                        destination: EventView(name: event.name, endDate: event.end, emoji: event.emoji, image: event.image))
                    {
                        ListCellView(name: event.name, emoji: event.emoji)
                    }
                }
            }
        }
        .listStyle(EllipticalListStyle())
    }
}

struct ContentView: View {
    @FetchRequest(
        fetchRequest: PersistenceController.allEventsFetchRequest()
    ) var fetchedEvents: FetchedResults<EventMO>
    
    var events: [Event] {
        fetchedEvents.compactMap(Event.init)
    }
    
    @StateObject var timer = Timer.publish(every: 1.0, on: .main, in: .common)
        .autoconnect()
        .observable(initialValue: Date())
        
    @Environment(\.managedObjectContext) var context: NSManagedObjectContext
    
    var body: some View {
        if events.isEmpty {
            NoEventsView()
        } else {
            NavigationView {
                ListView(events: events)
                    .environmentObject(timer)
                    .navigationTitle("My Events")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let store = PersistenceController.preview
        
        return Group {
            ContentView()
                .previewDevice("Apple Watch Series 5 - 44mm")
                .environment(\.managedObjectContext, store.container.viewContext)
            
            NoEventsView()
                .previewDevice("Apple Watch Series 5 - 44mm")
                .environment(\.managedObjectContext, store.container.viewContext)
        }
    }
}
