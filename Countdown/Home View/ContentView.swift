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
import WidgetKit

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
    
    var defaultImage: UnsplashImage {
        UnsplashResult.default.images.first!
    }
    
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

enum Modal: Identifiable {
    case settings, addEvent

    var id: Self {
        self
    }
}

struct HomeView: View {
    @Environment(\.managedObjectContext) var context: NSManagedObjectContext
    
    @EnvironmentObject var timer: ObservableTimer
        
    @AppStorage("pinnedEvent", store: UserDefaults.appGroup) var pinnedEventID: String?
    
    let events: [Event]
    let eventManager: EventManager
    
    @State var selectedEvent: Event? = nil
    @State var modal: Modal? = nil
    @State var modifiableEvent: Event? = nil
        
    var pinnedEvent: Event? {
        return events.first { $0.id.uuidString == pinnedEventID }
            ?? events.first { !$0.isOver }
            ?? events.first
    }
    
    func eventMenuItems(_ event: Event) -> EventMenuItems {
        let id = event.id.uuidString
        
        return EventMenuItems(isPinned: id == pinnedEventID) {
            self.modifiableEvent = event
        } onPin: { isPinned in
            UserDefaults.appGroup!.set(isPinned ? "" : id, forKey: "pinnedEvent")
            WidgetCenter.shared.reloadAllTimelines()
        } onDelete: {
            self.eventManager.removeEvent(from: context, event: event)
        }
    }
    
    func shouldShowUpcomingEvents() -> Bool {
        events ~= { !$0.isOver && $0 != pinnedEvent }
    }
    
    func shouldShowPastEvents() -> Bool {
        events ~= { $0.isOver && $0 != pinnedEvent }
    }
    
    func onOpenURL(_ url: URL) {
        guard url.scheme == URL.appScheme else {
            return
        }
        
        switch url.host {
        case URL.Hosts.addEvent:
            self.modal = .addEvent
            
        case URL.Hosts.viewPinned:
            self.selectedEvent = pinnedEvent
            
        default:
            return
        }
    }
    
    var body: some View {
        VStack {
            Header("My Events") {
                Image(systemName: "ellipsis.circle.fill")
                    .onTapGesture {
                        self.modal = .settings
                    }
                
                Image(systemName: "plus.circle.fill")
                    .onTapGesture {
                        self.modal = .addEvent
                    }
            }
            .background(Color.background)
            .padding(.horizontal, 20)
            .sheet(item: $modal) { modal in
                switch modal {
                case .addEvent:
                    AddEventView(modifying: modifiableEvent) { (data) in
                        if let data = data {
                            if let modified = modifiableEvent {
                                self.eventManager.removeEvent(from: context, event: modified)
                            }
                            
                            self.eventManager.addEvent(to: context, event: data)
                        }
                        
                        self.modifiableEvent = nil
                        self.modal = nil
                    }
                    
                case .settings:
                    SettingsView {
                        self.modal = nil
                        WidgetCenter.shared.reloadAllTimelines()
                    }
                }
            }
            
            if events.isEmpty {
                Spacer()
            } else {
                ScrollView {
                    VStack(alignment: .leading) {
                        if let first = pinnedEvent {
                            CardView(data: first)
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
                    .onChange(of: selectedEvent) { event in
                        if let event = event {
                            self.eventManager.reindex(event)
                        }
                    }
                    .onChange(of: modifiableEvent) { (event) in
                        if event != nil {
                            self.modal = .addEvent
                        }
                    }
                    .fullScreenCover(item: $selectedEvent) { event in
                        EventView(event: event) {
                            self.selectedEvent = nil
                        }
                        .environmentObject(timer)
                    }
                }
            }
        }
        .padding(.top, 20)
        .edgesIgnoringSafeArea(.bottom)
        .onOpenURL(perform: onOpenURL)
        .onContinueUserActivity(CSSearchableItemActionType) { activity in
            guard let id = activity.userInfo?[CSSearchableItemActivityIdentifier] as? String else { return }
            self.selectedEvent = events.first { $0.id.uuidString == id }!
        }
    }
}

struct ContentView: View {
    @FetchRequest(
        fetchRequest: CoreDataStore.allEventsFetchRequest()
    ) var fetchedEvents: FetchedResults<EventMO>
    
    var events: [Event] {
        fetchedEvents.compactMap(Event.init)
    }
    
    @StateObject var timer = Timer.publish(every: 1.0, on: .main, in: .common)
        .autoconnect()
        .observable(initialValue: Date())
    
    let eventManager: EventManager
    
    @Environment(\.managedObjectContext) var context: NSManagedObjectContext
    
    @State var shouldEmitConfetti: Bool = false
    @State var confettiEmoji: String = "🎉"
    
    @State var showModal: Bool = false
    
    @State var now: Date = Date()
    
    func update(_ date: Date) {
        if !showModal { now = date }
        
        if let event = events.first(where: { -1...0 ~= $0.end.timeIntervalSince(now) }) {
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
        ZStack {
            HomeView(events: events, eventManager: eventManager)
                .environmentObject(timer)
                .overlay(overlay)
                .confettiOverlay(confettiEmoji, emitWhen: $shouldEmitConfetti)
                .onReceive(timer.$output, perform: update)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let store = CoreDataStore(.inMemory)
        let manager = EventManager.shared
        
        MockData.all.forEach { manager.addEvent(to: store.context, event: $0) }
        
        return ContentView(eventManager: .shared)
            .environment(\.managedObjectContext, store.context)
            .previewDevice("iPhone 11 Pro")
    }
}
