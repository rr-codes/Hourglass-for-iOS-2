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

struct ModifyEventView: View {
    var event: Event?
    @Binding var isPresented: Bool
    var onDismiss: ((name: String, start: Date, end: Date, emoji: String, image: UnsplashImage)?) -> Void
    
    var body: some View {
        EmptyView()
    }
}

struct AsyncImage: View {
    let color: Color
    let url: URL
    
    var body: some View {
        URLImage(url, incremental: true, placeholder: { _ in color }) { (proxy) in
            proxy.image.resizable().aspectRatio(contentMode: .fill)
        }
    }
}

struct EventSection<Data: RandomAccessCollection>: View where Data.Element == Event {
    let name: String
    let data: Data
    let namespace: Namespace.ID
    
    let onEdit: (Event) -> Void
    let onDelete: (Event) -> Void
    
    var body: some View {
        Spacer().frame(height: 20)
        
        Text(name).font(.title3).bold().padding(.horizontal, 20)
        
        VStack(spacing: 0) {
            ForEach(data) { event in
                ListCellView(
                    imageURL: nil,
                    imageName: previewImages[event.name!] ?? "sample",
                    imageColor: .white,
                    date: event.end!,
                    emoji: event.emoji!,
                    name: event.name!
                )
                .matchedGeometryEffect(id: event.id, in: namespace)
                .background(Color.white)
                .contentShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .contextMenu {
                    Button {
                        onEdit(event)
                    } label: {
                        Text("Edit Event")
                        Image(systemName: "slider.horizontal.3")
                    }
                    
                    Button {
                        onDelete(event)
                    } label: {
                        Text("Delete Event")
                        Image(systemName: "trash")
                    }
                }
            }
        }
    }
}

struct ContentView: View {
    @FetchRequest(
        fetchRequest: DataProvider.allEventsFetchRequest()
    ) var events: FetchedResults<Event>
    
    @Environment(\.managedObjectContext) var context: NSManagedObjectContext
    
    @Namespace var namespace
    
    @State var modifiableEvent: Event?
    @State var showModifyView: Bool = false
    
    @State var selectedEvent: Event?
    @State var showEventView: Bool = false
    
    var upcomingEvents: ArraySlice<Event> {
        events.filter(\.isUpcoming).dropFirst()
    }
    
    var pastEvents: [Event] {
        events.filter(\.isOver)
    }
    
    func editEvent(_ event: Event) {
        self.modifiableEvent = event
        self.showModifyView = true
    }
    
    func deleteEvent(_ event: Event) {
        DataProvider.shared.removeEvent(from: context, event: event)
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
                        if let first = events.first(where: \.isUpcoming)! {
                            CardView(
                                imageURL: first.imageURL(size: .regular),
                                imageColor: first.imageColor,
                                date: first.end!,
                                emoji: first.emoji!,
                                name: first.name!
                            )
                            .padding(.horizontal, 20)
                            .matchedGeometryEffect(id: first.id, in: namespace)
                            .padding(.bottom, 10)
                        }
                        
                        if events.contains(where: \.isUpcoming) {
                            EventSection(
                                name: "Upcoming",
                                data: upcomingEvents,
                                namespace: namespace,
                                onEdit: editEvent,
                                onDelete: deleteEvent
                            )
                        }
                        
                        if events.contains(where: \.isOver) {
                            EventSection(
                                name: "Past",
                                data: pastEvents,
                                namespace: namespace,
                                onEdit: editEvent,
                                onDelete: deleteEvent
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
