//
//  ContentView.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-07-23.
//

import SwiftUI
import CoreData
import URLImage

let previewImages: [String : String] = [
    "New Year's Day" : "ny",
    "Christmas" : "christmas"
]

struct AsyncImage: View {
    let color: Color
    let url: URL
    
    var body: some View {
        URLImage(url, incremental: true, placeholder: { _ in Rectangle().fill(color) }) { (proxy) in
            proxy.image.resizable().aspectRatio(contentMode: .fill)
        }
    }
}

struct EventSection<Data: RandomAccessCollection>: View where Data.Element == Event {
    let name: String
    let data: Data
    let namespace: Namespace.ID
    
    let menuItems: (Event) -> EventMenuItems
    
    var body: some View {
        Spacer().frame(height: 20)
        
        Text(name).font(.title3).bold().padding(.horizontal, 20)
        
        VStack(spacing: 0) {
            ForEach(data) { event in
                ListCellView(
                    imageURL: event.image.url(for: .regular),
                    imageColor: event.image.overallColor,
                    date: event.end,
                    emoji: event.emoji,
                    name: event.name
                )
                .matchedGeometryEffect(id: event.id, in: namespace)
                .background(Color.white)
                .contentShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .contextMenu {
                    menuItems(event)
                }
            }
        }
    }
}

struct EventMenuItems: View {
    let onEdit: () -> Void
    let onPin: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        Button(action: onEdit) {
            Text("Edit Event")
            Image(systemName: "slider.horizontal.3")
        }
        
        Button(action: onPin) {
            Text("Pin Event")
            Image(systemName: "pin")
        }
        
        Button(action: onDelete) {
            Text("Delete Event")
            Image(systemName: "trash")
        }
    }
}

struct ContentView: View {
    @FetchRequest(
        fetchRequest: DataProvider.allEventsFetchRequest()
    ) var events: FetchedResults<Event>
    
    @AppStorage("pinnedEvent") var pinnedEventID: String?
    
    @Environment(\.managedObjectContext) var context: NSManagedObjectContext
    
    @Namespace var namespace
    
    @State var modifiableEvent: Event?
    @State var showModifyView: Bool = false
    
    @State var selectedEvent: Event?
    @State var showEventView: Bool = false
    
    var pinnedEvent: Event? {
        return events.first { $0.id.uuidString == pinnedEventID }
            ?? events.first { !$0.isOver }
            ?? events.first
    }
    
    func eventMenuItems(_ event: Event) -> EventMenuItems {
        EventMenuItems {
            self.modifiableEvent = event
            self.showModifyView = true
        } onPin: {
            UserDefaults.standard.set(event.id.uuidString, forKey: "pinnedEvent")
        } onDelete: {
            DataProvider.shared.removeEvent(from: context, event: event)
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("My Events").font(.title).bold()
                Spacer()
                Image(systemName: "plus.circle.fill")
                    .imageScale(.large)
                    .scaleEffect(1.2)
            }
            .background(Color.white)
            .padding(.horizontal, 20)
            
            if events.isEmpty {
                Spacer()
            } else {
                ScrollView {
                    VStack(alignment: .leading) {
                        if let first = pinnedEvent {
                            CardView(
                                imageURL: first.image.url(for: .regular),
                                imageColor: first.image.overallColor,
                                date: first.end,
                                emoji: first.emoji,
                                name: first.name
                            )
                            .padding(.horizontal, 20)
                            .matchedGeometryEffect(id: first.id, in: namespace)
                            .padding(.bottom, 10)
                            .background(Color.white)
                            .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .contextMenu {
                                eventMenuItems(first)
                            }
                        }
                        
                        if events.contains(where: { !$0.isOver }) {
                            EventSection(
                                name: "Upcoming",
                                data: events.filter { !$0.isOver && $0 != pinnedEvent},
                                namespace: namespace,
                                menuItems: eventMenuItems
                            )
                        }
                        
                        if events.contains(where: \.isOver) {
                            EventSection(
                                name: "Past",
                                data: events.filter(\.isOver),
                                namespace: namespace,
                                menuItems: eventMenuItems
                            )
                        }
                    }
                }
            }
        }
        .padding(.top, 20)
        .edgesIgnoringSafeArea(.bottom)
        .overlay(
            events.isEmpty
                ? AnyView(PlaceholderView())
                : AnyView(EmptyView())
        )
        
        //        URLImage(events.first!.imageURL(size: .regular), incremental: true)
        //            .sheet(isPresented: $showModifyView) {
        //                ModifyEventView(event: modifiableEvent, isPresented: $showModifyView) { params in
        //                    guard let params = params else { return }
        //
        //                    if let modified = modifiableEvent {
        //                        DataProvider.shared.removeEvent(from: context, event: modified)
        //                    }
        //
        //                    DataProvider.shared.addEvent(to: context, configuration: params)
        //                }
        //            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewCoreDataWrapper { context in
            ContentView()
                .environment(\.managedObjectContext, context)
                .previewDevice("iPhone 11 Pro")
        }
    }
}
