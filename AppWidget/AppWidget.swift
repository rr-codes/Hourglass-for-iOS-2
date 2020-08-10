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
    let context: NSManagedObjectContext?
    
    private var pinnedEntry: SimpleEntry {
        let fetchRequest = CoreDataStore.allEventsFetchRequest()
        let events = try? context?.fetch(fetchRequest).compactMap(Event.init)
        
        let pinnedEventID = UserDefaults.appGroup?.string(forKey: "pinnedEvent")

        let pinned = events?.first { $0.id.uuidString == pinnedEventID }
            ?? events?.first { !$0.isOver }
            ?? events?.first
        
        let tuple = pinned.map { ($0.id, $0.name, $0.emoji) }
        return SimpleEntry(date: pinned?.end ?? Date(), props: tuple)
    }
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            props: (id: UUID(), name: "---------", emoji: "-")
        )
    }
    
    public func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        completion(pinnedEntry)
    }
    
    public func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        let timeline = Timeline(entries: [pinnedEntry], policy: .after(pinnedEntry.date))
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let props: (id: UUID, name: String, emoji: String)?
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
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    let date: Date
    let props: (id: UUID, name: String, emoji: String)
    
    let viewEventURL: URL? = {
        var components = URLComponents()
        components.scheme = URL.appScheme
        components.host = URL.Hosts.viewPinned
        return components.url
    }()
    
    var gradient: some ShapeStyle {
        AngularGradient(
            gradient: Gradient(colors: [.red, .yellow, .green, .blue, .purple, .red]),
            center: .center,
            startAngle: .zero,
            endAngle: .degrees(360)
        )
    }
    
    var text: Text {
        date < Date()
            ? Text("Complete!")
            : Text(date, style: .relative)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(props.name)
                .font(.caption)
                .bold()
                .textCase(.uppercase)
                .foregroundColor(.secondary)
                .padding(.top, 8)
            
            Spacer().height(4)

            self.text
                .font(.headline)
                .bold()
            
            Spacer()
            
            HStack {
                Circle()
                    .fill(gradient)
                    .opacity(0.05)
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
        .background(colorScheme == .dark
                        ? Color(UIColor.systemGray6)
                        : Color.white
        )
    }
}

struct WidgetView: View {
    let date: Date
    let props: (id: UUID, name: String, emoji: String)?
    
    var body: some View {
        if let props = props {
            AppWidgetEntryView(date: date, props: props)
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
            WidgetView(date: entry.date, props: entry.props)
        }
        .configurationDisplayName("Pinned Event")
        .description("Displays the time remaining for your pinned Event.")
        .supportedFamilies([.systemSmall])
    }
}

struct AppWidget_Previews: PreviewProvider {
    static let props = (id: UUID(), name: "My Birthday", emoji: "🥳")
    
    static var previews: some View {
        Group {
            AppWidgetEntryView(
                date: Date(timeIntervalSinceNow: 1500),
                props: props
            )
            .previewContext(WidgetPreviewContext(family: .systemSmall))
            
            EmptyWidgetView().previewContext(WidgetPreviewContext(family: .systemSmall))
        }
    }
}
