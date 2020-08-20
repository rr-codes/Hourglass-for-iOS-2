//
//  AppWidget.swift
//  AppWidget
//
//  Created by Richard Robinson on 2020-08-03.
//

import WidgetKit
import SwiftUI
import CoreData

struct Provider: TimelineProvider {
    typealias Intent = WidgetColorSelectionIntent
    
    let context: NSManagedObjectContext?
    
    private func getPinnedEntry() -> SimpleEntry {
        let fetchRequest = CoreDataStore.allEventsFetchRequest()
        let events = try? context?.fetch(fetchRequest).compactMap(Event.init)
        
        let pinnedEventID = UserDefaults.appGroup?.string(forKey: "pinnedEvent")
        let index = UserDefaults.appGroup?.integer(forKey: "gradientIndex") ?? 0

        let pinned = events?.first { $0.id.uuidString == pinnedEventID }
            ?? events?.first { !$0.isOver }
            ?? events?.first
        
        guard let event = pinned else {
            return .init(date: Date(), props: nil, gradientIndex: index)
        }
        
        let tuple = (event.id, event.name, event.emoji)
        return .init(date: event.end, props: tuple, gradientIndex: index)
    }
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            props: (id: UUID(), name: "---------", emoji: "-"),
            gradientIndex: 0
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        completion(getPinnedEntry())
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        let entry = getPinnedEntry()
        let timeline = Timeline(entries: [entry], policy: .after(entry.date))
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let props: (id: UUID, name: String, emoji: String)?
    let gradientIndex: Int
}

struct EmptyWidgetView: View {
    let addEventURL: URL? = {
        var components = URLComponents()
        components.scheme = URL.appScheme
        components.host = URL.Hosts.addEvent
        return components.url
    }()
    
    var body: some View {
        Text("No Events")
            .font(.footnote)
            .bold()
            .foregroundColor(.secondary)
            .widgetURL(addEventURL)
    }
}

struct AppWidgetEntryView : View {
    let date: Date
    let props: (id: UUID, name: String, emoji: String)
    let gradientIndex: Int
    
    let viewEventURL: URL? = {
        var components = URLComponents()
        components.scheme = URL.appScheme
        components.host = URL.Hosts.viewPinned
        return components.url
    }()
    
    var text: Text {
        date < Date()
            ? Text("Complete!")
            : Text(date, style: .relative)
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(props.name)
                .foregroundColor(.white)
                .font(.caption)
                .bold()
                .textCase(.uppercase)
                .foregroundColor(.secondary)
                .padding(.top, 8)
                .opacity(0.75)
            
            Spacer().height(4)

            self.text
                .foregroundColor(.white)
                .font(.headline)
                .bold()
            
            Spacer()
            
            HStack {
                Circle()
                    .fill(Color.white)
                    .opacity(0.2)
                    .overlay(
                        Text(props.emoji).font(.body)
                    )
                    .width(40)
                
                Spacer()
            }
            .padding(.bottom, -20)
        }
        .padding()
        .widgetURL(viewEventURL)
        .background(
            LinearGradient(
                gradient: Gradient.all[gradientIndex],
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            )
        )
    }
}

struct WidgetView: View {
    let date: Date
    let props: (id: UUID, name: String, emoji: String)?
    let gradientIndex: Int

    var body: some View {
        if let props = props {
            AppWidgetEntryView(date: date, props: props, gradientIndex: gradientIndex)
        } else {
            EmptyWidgetView()
        }
    }
}

@main
struct AppWidget: Widget {
    @StateObject private var store = CoreDataStore.shared
    
    private let kind: String = "AppWidget"
    
    public var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider(context: store.context)) { entry in
            WidgetView(date: entry.date, props: entry.props, gradientIndex: entry.gradientIndex)
        }
        .configurationDisplayName("Pinned Event")
        .description("Displays the time remaining for your pinned Event.")
        .supportedFamilies([.systemSmall])
    }
}

struct AppWidget_Previews: PreviewProvider {
    static let props = (id: UUID(), name: "My Birthday", emoji: "🇬🇷")
    static let props2 = (id: UUID(), name: "My Birthday", emoji: "😍")
    
    @State static var image: Image? = nil
    
    static var previews: some View {
        Group {
            AppWidgetEntryView(
                date: Date(timeIntervalSinceNow: 1500),
                props: props,
                gradientIndex: Int.random(in: 0...10)
            )
            .previewContext(WidgetPreviewContext(family: .systemSmall))
            
            AppWidgetEntryView(
                date: Date(timeIntervalSinceNow: 1500),
                props: props2,
                gradientIndex: Int.random(in: 0...10)
            )
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        }
    }
}
