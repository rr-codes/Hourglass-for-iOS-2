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
    
    @AppStorage("hourglass-pinnedID", store: .appGroup) var id: UUID? = nil
    @AppStorage("gradientIndex", store: .appGroup) var index: Int?
    
    private func getPinnedEntry(for date: Date) -> SimpleEntry {
        let fetchRequest = PersistenceController.allEventsFetchRequest()
        let events = try! context?.fetch(fetchRequest).compactMap(Event.init)

        let pinned = events?.first { $0.id == id }
            ?? events?.first { !$0.isOver }
            ?? events?.first
        
        guard let event = pinned else {
            return .init(date: date, props: nil, gradientIndex: index ?? 0)
        }
        
        let tuple = (event.id, event.name, event.emoji, event.end)
        return .init(date: date, props: tuple, gradientIndex: index ?? 0)
    }
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            props: (id: UUID(), name: "---------", emoji: "-", endDate: Date()),
            gradientIndex: 0
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        completion(getPinnedEntry(for: Date()))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        let now = Date()
        let currentEntry = getPinnedEntry(for: now)
        let endDate = currentEntry.props?.endDate ?? Date()
        
        if endDate < now.addingTimeInterval(60 * 60 * 24 * 7) {
            let timeline = Timeline(entries: [currentEntry], policy: .after(endDate))
            completion(timeline)
            return
        }
        
        let entries = (0..<24).map { (i) -> SimpleEntry in
            let date = Calendar.current.date(byAdding: .hour, value: i, to: Date())!
            return getPinnedEntry(for: date)
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let props: (id: UUID, name: String, emoji: String, endDate: Date)?
    let gradientIndex: Int
}

struct EmptyWidgetView: View {
    let emojiString = ["🥳", "🍭", "🎉"].joined(separator: "  ")

    let addEventURL: URL? = {
        var components = URLComponents()
        components.scheme = URL.appScheme
        components.host = URL.Hosts.addEvent
        return components.url
    }()
    
    var body: some View {
        VStack {
            Text(emojiString).font(.title2)
            
            Spacer().height(16)
            
            Text("No Events")
                .font(.footnote)
                .bold()
                .foregroundColor(.secondary)
                .widgetURL(addEventURL)
        }
    }
}

struct AppWidgetEntryView : View {
    let date: Date
    let props: (id: UUID, name: String, emoji: String, endDate: Date)
    let gradientIndex: Int
    
    let formatter: DateComponentsFormatter = {
        let dcf = DateComponentsFormatter()
        dcf.maximumUnitCount = 2
        dcf.allowedUnits = [.day, .hour]
        dcf.unitsStyle = .short
        return dcf
    }()
    
    let viewEventURL: URL? = {
        var components = URLComponents()
        components.scheme = URL.appScheme
        components.host = URL.Hosts.viewPinned
        return components.url
    }()
    
    var text: Text {
        switch props.endDate {
        case ...date:
            return Text("Complete!")
            
        case ...date.addingTimeInterval(60 * 60 * 24 * 7):
            return Text(props.endDate, style: .relative)
            
        default:
            return Text(formatter.string(from: date, to: props.endDate)!)
        }
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
    let props: (id: UUID, name: String, emoji: String, endDate: Date)?
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
    private let store = PersistenceController.shared
    
    private let kind: String = "AppWidget"
    
    public var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider(context: store.container.viewContext)) { entry in
            WidgetView(date: entry.date, props: entry.props, gradientIndex: entry.gradientIndex)
        }
        .configurationDisplayName("Pinned Event")
        .description("Displays the time remaining for your pinned Event.")
        .supportedFamilies([.systemSmall])
    }
}

struct AppWidget_Previews: PreviewProvider {
    static let props = (id: UUID(), name: "My Birthday", emoji: "🇬🇷", endDate: Date(timeIntervalSinceNow: 86400*14+10000))
    static let props2 = (id: UUID(), name: "My Birthday", emoji: "😍", endDate: Date(timeIntervalSinceNow: 1500))
    
    @State static var image: Image? = nil
    
    static var previews: some View {
        Group {
            AppWidgetEntryView(
                date: Date(),
                props: props,
                gradientIndex: Int.random(in: 0...10)
            )
            .previewContext(WidgetPreviewContext(family: .systemSmall))
            
            AppWidgetEntryView(
                date: Date(),
                props: props2,
                gradientIndex: Int.random(in: 0...10)
            )
            .previewContext(WidgetPreviewContext(family: .systemSmall))
            
            WidgetView(
                date: Date(),
                props: nil,
                gradientIndex: Int.random(in: 0...10)
            )
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        }
    }
}
