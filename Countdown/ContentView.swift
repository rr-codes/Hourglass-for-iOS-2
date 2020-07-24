//
//  ContentView.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-07-23.
//

import SwiftUI
import CoreData
import URLImage

struct ModifyEventView: View {
    var event: Event?
    @Binding var isPresented: Bool
    var onDismiss: ((name: String, start: Date, end: Date, emoji: String, image: UnsplashImage)?) -> Void
    
    var body: some View {
        EmptyView()
    }
}

struct CardView: View {
    let event: Event
    
    var url: URL {
        event.imageURL(size: .regular)
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(event.imageColor)
            .overlay(
                AsyncImage(color: event.imageColor, url: event.imageURL(size: .regular))
            )
            .frame(height: 225)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: event.imageColor.opacity(0.1), radius: 2, x: 0, y: 2)

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

struct ContentView: View {
    @FetchRequest(
        fetchRequest: DataProvider.allEventsFetchRequest()
    ) var events: FetchedResults<Event>
    
    @Environment(\.managedObjectContext) var context: NSManagedObjectContext
    
    @State var modifiableEvent: Event?
    @State var showModifyView: Bool = false
    
    var header: some View {
        HStack {
            Text("My Events").font(.title).bold()
            Spacer()
            Image(systemName: "plus.circle.fill")
                .imageScale(.large)
                .scaleEffect(1.2)
        }
        .background(Color.white)
    }
    
    var body: some View {
        VStack {
            header
            ScrollView {
                CardView(event: events.first!)
            }
        }
        .padding(.all, 20)
        
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
