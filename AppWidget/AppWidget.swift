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
        fetchRequest.fetchLimit = 1
        let events = try? context?.fetch(fetchRequest).compactMap(Event.init)
        
        let pinnedEventID = UserDefaults.appGroup?.string(forKey: "pinnedEvent")
        
        let pinned = events?.first { $0.id.uuidString == pinnedEventID }
            ?? events?.first { !$0.isOver }
            ?? events?.first
        
        let tuple = pinned.map { ($0.id, $0.name, $0.emoji) }
        return SimpleEntry(date: pinned?.end ?? Date(), props: tuple, isPlaceholder: false)
    }
    
    func placeholder(with context: Context) -> SimpleEntry {
        SimpleEntry(
            date: .init(timeIntervalSinceNow: 86400 - 60),
            props: (id: UUID(), name: "My Birthday", emoji: "🎉"),
            isPlaceholder: true
        )
    }
    
    public func snapshot(with context: Context, completion: @escaping (SimpleEntry) -> ()) {
        completion(pinnedEntry)
    }
    
    public func timeline(with context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        let timeline = Timeline(entries: [pinnedEntry], policy: .after(pinnedEntry.date))
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let props: (id: UUID, name: String, emoji: String)?
    let isPlaceholder: Bool
}

struct EmptyWidgetView: View {
    var body: some View {
        Text("No Events")
            .font(.footnote)
            .bold()
            .foregroundColor(.secondary)
    }
}

struct AppWidgetEntryView : View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    var entry: Provider.Entry
    
    let urlComponents: URLComponents = {
        var components = URLComponents()
        components.scheme = URL.deepLinkScheme
        components.host = URL.viewEventHost
        components.queryItems = ["event" : "pinned"].map(URLQueryItem.init)
        return components
    }()
    
    var gradient: some ShapeStyle {
        AngularGradient(
            gradient: Gradient(colors: [.red, .yellow, .green, .blue, .purple, .red]),
            center: .center,
            startAngle: .zero,
            endAngle: .degrees(360)
        )
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(entry.props?.name ?? "")
                .font(.caption)
                .bold()
                .textCase(.uppercase)
                .foregroundColor(.secondary)
                .padding(.top, 8)
            
            Spacer().height(4)

            Text(entry.date, style: .relative)
                .font(.headline)
                .bold()
            
            Spacer()
            
            HStack {
                Circle()
                    .fill(gradient)
                    .opacity(0.1)
                    .overlay(
                        Text(entry.props?.emoji ?? "").font(.body)
                    )
                    .width(40)
                
                Spacer()
            }
            .padding(.bottom, -20)
        }
        .padding()
        .widgetURL(urlComponents.url)
        .redacted(if: entry.isPlaceholder, reason: .placeholder)
        .background(colorScheme == .dark
                        ? Color(UIColor.systemGray6)
                        : Color.white
        )
    }
}

@main
struct AppWidget: Widget {
    @StateObject private var store = CoreDataStore.shared
    
    private let kind: String = "AppWidget"
    
    public var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider(context: store.context)) { entry in
            entry.props != nil
                ? AppWidgetEntryView(entry: entry).eraseToAnyView()
                : EmptyWidgetView().eraseToAnyView()
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
                entry: SimpleEntry(
                    date: Date(timeIntervalSinceNow: 600),
                    props: props,
                    isPlaceholder: false
                )
            )
            .previewContext(WidgetPreviewContext(family: .systemSmall))
            
            EmptyWidgetView().previewContext(WidgetPreviewContext(family: .systemSmall))
        }
    }
}
