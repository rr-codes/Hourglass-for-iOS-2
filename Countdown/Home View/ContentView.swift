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
    let onTap: (Event) -> Void
    
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
                .matchedGeometryEffect(id: event.id, in: namespace, isSource: true)
                .background(Color.white)
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

struct ContentView: View {
    @FetchRequest(
        fetchRequest: DataProvider.allEventsFetchRequest()
    ) var events: FetchedResults<Event>
    
    @AppStorage("pinnedEvent", store: DataProvider.shared.defaults) var pinnedEventID: String?
    
    @Environment(\.managedObjectContext) var context: NSManagedObjectContext
    
    @Namespace var namespace
    
    @State var modifiableEvent: Event?
    @State var showModifyView: Bool = false
    
    @State var selectedEvent: Event?
    @State var showEventView: Bool = false
    
    @State var now: Date = Date()
    @State var shouldEmitConfetti: Bool = false
    @State var confettiEmoji: String = "🎉"
        
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // The pinned event, if any, or else the first upcoming event, if any, or else the first event, if any
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
            UserDefaults.standard.set(isPinned ? "" : id, forKey: "pinnedEvent")
        } onDelete: {
            EventManager.removeEvent(from: context, event: event)
        }
    }
    
    func shouldShowUpcomingEvents() -> Bool {
        let upcomingEvents = events.filter({ !$0.isOver && $0 != pinnedEvent})
        return !upcomingEvents.isEmpty
    }
    
    func shouldShowPastEvents() -> Bool {
        let pastEvents = events.filter({ $0.isOver && $0 != pinnedEvent})
        return !pastEvents.isEmpty
    }
    
    var body: some View {
        ZStack {
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
                .background(Color.white)
                .padding(.horizontal, 20)
                
                if events.isEmpty {
                    Spacer()
                } else {
                    ScrollView {
                        VStack(alignment: .leading) {
                            if let first = pinnedEvent {
                                CardView(
                                    data: first.properties,
                                    namespace: namespace,
                                    isSource: !showEventView,
                                    id: first.id
                                )
                                .padding(.horizontal, 20)
                                .padding(.bottom, 10)
                                .background(Color.white)
                                .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .contextMenu {
                                    eventMenuItems(first)
                                }
                                .onTapGesture {
                                    withAnimation(.spring()) {
                                        self.selectedEvent = first
                                    }
                                }
                            }
                            
                            if shouldShowUpcomingEvents() {
                                EventSection(
                                    name: "Upcoming",
                                    data: events.filter { !$0.isOver && $0 != pinnedEvent},
                                    namespace: namespace,
                                    menuItems: eventMenuItems
                                ) { event in
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0)) {
                                        showEventView.toggle()
                                        selectedEvent = event
                                    }
                                }
                            }
                            
                            if shouldShowPastEvents() {
                                EventSection(
                                    name: "Past",
                                    data: events.filter(\.isOver),
                                    namespace: namespace,
                                    menuItems: eventMenuItems
                                ) { event in
                                    withAnimation {
                                        self.selectedEvent = event
                                    }
                                }
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
            .sheet(isPresented: $showModifyView) {
                AddEventView(modifying: modifiableEvent.map(\.properties)) { (data) in
                    if let data = data {
                        if let modified = modifiableEvent {
                            EventManager.removeEvent(from: context, event: modified)
                        }
                        
                        EventManager.addEvent(to: context, configuration: data)
                    }
                    
                    self.modifiableEvent = nil
                    
                    withAnimation {
                        self.showModifyView = false
                    }
                }
            }
            .zIndex(1)
            .frame(maxWidth: .infinity)
            
            if let event = selectedEvent {
                EventView(
                    id: event.id,
                    namespace: namespace,
                    image: event.image,
                    name: event.name,
                    date: event.end,
                    emoji: event.emoji
                ) {
                    withAnimation(.spring()) {
                        showEventView.toggle()
                        self.selectedEvent = nil
                    }
                }
                .zIndex(2)
            }
            
            EmptyView().id(self.now)
        }
        .animation(.spring())
        .transition(.scale)
        .confettiOverlay(confettiEmoji, emitWhen: $shouldEmitConfetti)
        .onReceive(timer) { _ in
            guard !showModifyView else {
                return
            }
            
            if !showModifyView { self.now = Date() }
            
            if let event = events.first(where: { -1...0 ~= $0.end.timeIntervalSinceNow }) {
                self.confettiEmoji = event.emoji
                self.shouldEmitConfetti = true
            }
        }
        .onContinueUserActivity(CSSearchableItemActionType) { activity in
            guard let id = activity.userInfo?[CSSearchableItemActivityIdentifier] as? String else { return }
            self.selectedEvent = events.first { $0.id.uuidString == id }!
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let container = DataProvider.shared.container
        
        return ContentView()
            .environment(\.managedObjectContext, container.viewContext)
            .previewDevice("iPhone 11 Pro")
    }
}
