//
//  ContentView.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-07-23.
//

import SwiftUI
import CoreData
import URLImage
import CoreSpotlight

extension View {
    func extraSheet<Content: View>(
        isPresented: Binding<Bool>,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        self.background(EmptyView().sheet(isPresented: isPresented, onDismiss: onDismiss, content: content))
    }
}

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
    
    let menuItems: (Event) -> EventMenuItems
    let onTap: (Event) -> Void
    
    var body: some View {
        Spacer().frame(height: 20)
        
        Text(name).font(.title3).bold().padding(.horizontal, 20)
        
        VStack(spacing: 0) {
            ForEach(data) { event in
                ListCellView(
                    imageURL: event.image.url(for: .small),
                    imageColor: event.image.overallColor,
                    date: event.end,
                    emoji: event.emoji,
                    name: event.name
                )
                .background(Color.background)
                .contentShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .contextMenu {
                    menuItems(event)
                }
                .onTapGesture {
                    onTap(event)
                }
            }
        }
    }
}

struct EventMenuItems: View {
    let isPinned: Bool
    
    let onEdit: () -> Void
    let onPin: (Bool) -> Void
    let onDelete: () -> Void
    
    var body: some View {
        Button(action: onEdit) {
            Text("Edit Event")
            Image(systemName: "slider.horizontal.3")
        }
        
        Button {
            onPin(isPinned)
        } label: {
            Text(isPinned ? "Unpin Event" : "Pin Event")
            Image(systemName: isPinned ? "pin.slash" : "pin")
        }
        
        Button(action: onDelete) {
            Text("Delete Event")
            Image(systemName: "trash")
        }
    }
}

struct HomeView: View {
    @Environment(\.managedObjectContext) var context: NSManagedObjectContext

    let events: FetchedResults<Event>
    let pinnedEventID: String?
    
    @Binding var selectedEvent: Event?
    @Binding var modifiableEvent: Event?
    @Binding var showModifyView: Bool
    
    var pinnedEvent: Event? {
        return events.first { $0.id.uuidString == pinnedEventID }
            ?? events.first { !$0.isOver }
            ?? events.first
    }
    
    func eventMenuItems(_ event: Event) -> EventMenuItems {
        let id = event.id.uuidString
        
        return EventMenuItems(isPinned: id == pinnedEventID) {
            self.modifiableEvent = event
            self.showModifyView = true
        } onPin: { isPinned in
            UserDefaults.appGroup!.set(isPinned ? "" : id, forKey: "pinnedEvent")
        } onDelete: {
            EventManager.shared.removeEvent(from: context, event: event)
        }
    }
    
    func shouldShowUpcomingEvents() -> Bool {
        let upcomingEvents = events.filter { !$0.isOver && $0 != pinnedEvent}
        return !upcomingEvents.isEmpty
    }
    
    func shouldShowPastEvents() -> Bool {
        let pastEvents = events.filter { $0.isOver && $0 != pinnedEvent}
        return !pastEvents.isEmpty
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("My Events").font(.title).bold()
                Spacer()
                Image(systemName: "plus.circle.fill")
                    .imageScale(.large)
                    .scaleEffect(1.2)
                    .offset(x: -3, y: -0)
                    .onTapGesture {
                        withAnimation {
                            self.showModifyView = true
                        }
                    }
            }
            .background(Color.background)
            .padding(.horizontal, 20)
            
            if events.isEmpty {
                Spacer()
            } else {
                ScrollView {
                    VStack(alignment: .leading) {
                        if let first = pinnedEvent {
                            CardView(data: first.properties)
                                .padding(.horizontal, 20)
                                .padding(.bottom, 10)
                                .background(Color.background)
                                .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .contextMenu {
                                    eventMenuItems(first)
                                }
                                .onTapGesture {
                                    self.selectedEvent = first
                                }
                        }
                        
                        if shouldShowUpcomingEvents() {
                            EventSection(
                                name: "Upcoming",
                                data: events.filter { !$0.isOver && $0 != pinnedEvent },
                                menuItems: eventMenuItems
                            ) { event in
                                selectedEvent = event
                            }
                        }
                        
                        if shouldShowPastEvents() {
                            EventSection(
                                name: "Past",
                                data: events.filter { $0.isOver && $0 != pinnedEvent },
                                menuItems: eventMenuItems
                            ) { event in
                                selectedEvent = event
                            }
                        }
                    }
                }
            }
        }
        .padding(.top, 20)
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct ContentView: View {
    @FetchRequest(
        fetchRequest: CoreDataStore.allEventsFetchRequest()
    ) var events: FetchedResults<Event>
    
    @AppStorage("pinnedEvent", store: UserDefaults.appGroup) var pinnedEventID: String?
    
    @Environment(\.managedObjectContext) var context: NSManagedObjectContext
    @Environment(\.eventManager) var eventManager: EventManager
        
    @State var modifiableEvent: Event?
    @State var showModifyView: Bool = false
    
    @State var selectedEvent: Event?
    
    @State var now: Date = Date()
    @State var shouldEmitConfetti: Bool = false
    @State var confettiEmoji: String = "🎉"
        
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    func update(_ param: Any) {
        guard !showModifyView else {
            return
        }
        
        self.now = Date()
        
        if let event = events.first(where: { -1...0 ~= $0.end.timeIntervalSinceNow }) {
            self.confettiEmoji = event.emoji
            self.shouldEmitConfetti = true
        }
    }
    
    @ViewBuilder
    var overlay: some View {
        if events.isEmpty {
            PlaceholderView()
        } else {
            EmptyView()
        }
    }
    
    var body: some View {
        HomeView(
            events: events,
            pinnedEventID: pinnedEventID,
            selectedEvent: $selectedEvent,
            modifiableEvent: $modifiableEvent,
            showModifyView: $showModifyView
        )
        .overlay(overlay)
        .fullScreenCover(item: $selectedEvent) { event in
            EventView(image: event.image, name: event.name, date: event.end, emoji: event.emoji) {
                self.selectedEvent = nil
            }
        }
        .extraSheet(isPresented: $showModifyView) {
            AddEventView(modifying: modifiableEvent.map(\.properties)) { (data) in
                if let data = data {
                    if let modified = modifiableEvent {
                        self.eventManager.removeEvent(from: context, event: modified)
                    }
                    
                    self.eventManager.addEvent(to: context, configuration: data)
                }
                
                self.modifiableEvent = nil
                self.showModifyView = false
            }
        }
        .confettiOverlay(confettiEmoji, emitWhen: $shouldEmitConfetti)
        .onReceive(timer, perform: update)
        .onContinueUserActivity(CSSearchableItemActionType) { activity in
            guard let id = activity.userInfo?[CSSearchableItemActivityIdentifier] as? String else { return }
            self.selectedEvent = events.first { $0.id.uuidString == id }!
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let store = CoreDataStore(.inMemory)
        
        MockData.all.forEach { EventManager.shared.addEvent(to: store.context, configuration: $0) }
        
        return ContentView()
            .preferredColorScheme(.dark)
            .environment(\.managedObjectContext, store.context)
            .previewDevice("iPhone 11 Pro")
    }
}
