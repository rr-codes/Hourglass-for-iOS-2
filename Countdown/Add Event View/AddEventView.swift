//
//  AddEventView.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-07-25.
//

import SwiftUI
import Combine

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension Color {
    static let background: Self = .init(.systemBackground)
    static let foreground: Self = .init(.label)
}

struct CTAButtonStyle: ButtonStyle {
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Font.body.weight(.semibold))
            .foregroundColor(.background)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(color)
            )
    }
}

struct StylizedTextField: View {
    @Binding var text: String
    @Binding var showEmojiPicker: Bool
    @Binding var emoji: String
    
    let onEditingChanged: (Bool) -> Void
    let onCommit: () -> Void
    
    var body: some View {
        Text("What's the occasion?")
            .bold()
            .padding(.bottom, 10)
        
        HStack {
            TextField("New Year's Day", text: $text, onEditingChanged: onEditingChanged, onCommit: onCommit)
                .autocapitalization(.words)
                .padding(.leading, 10)
                .font(Font.body.weight(.medium))
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.foreground.opacity(0.05))
                        .padding(.vertical, -10)
                )
                .padding(.trailing, 10)
            
            Text(emoji)
                .background(
                    Circle()
                        .fill(Color.foreground.opacity(0.05))
                        .frame(width: 42, height: 42)
                )
                .width(44)
                .onTapGesture {
                    showEmojiPicker.toggle()
                    UIApplication.shared.endEditing()
                }
        }
        .height(44)
    }
}

struct DateView: View {
    @Binding var date: Date
    
    @State private var show: Bool = false
    
    var formatter: DateFormatter {
        let df = DateFormatter()
        df.dateStyle = .long
        df.timeStyle = .short
        return df
    }
    
    var body: some View {
        Text("When's it happening?")
            .bold()
            .padding(.bottom, 10)
        
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.foreground.opacity(0.05))
                .height(41)
            
            Text(formatter.string(from: date))
                .padding(.leading, 10)
                .font(Font.body.weight(.medium))
                .onTapGesture {
                    UIApplication.shared.endEditing()
                    
                    withAnimation {
                        self.show.toggle()
                    }
                }
        }
        
        if show {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.black.opacity(0.03))
                
                DatePicker("Select a Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                    .labelsHidden()
                    .datePickerStyle(GraphicalDatePickerStyle())
            }
            .height(350)
            .mask(Rectangle().height(show ? 350 : 0))
        }
    }
}

struct ImagePicker: View {
    var allImages: [UnsplashImage]
    @Binding var selectedImage: UnsplashImage?
    
    private let rows = [GridItem](repeating: GridItem(.flexible()), count: 2)
    
    private func imageView(_ image: UnsplashImage) -> some View {
        AsyncImage(color: image.overallColor, url: image.url(for: .small))
            .frame(width: 100, height: 100)
            .clipShape(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(lineWidth: 3.0)
                    .foregroundColor(self.selectedImage == image ? .blue : .clear)
            )
            .scaleEffect(self.selectedImage == image ? 0.98 : 1.0)
            .onTapGesture {
                withAnimation(.linear(duration: 0.05)) {
                    self.selectedImage = image
                }
            }
    }
    
    var body: some View {
        Text("Choose a background")
            .bold()
            .padding(.bottom, 10)
        
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHGrid(rows: rows) {
                ForEach(allImages, content: imageView)
            }
        }
        .height(210)
        .onChange(of: allImages) { newValue in
            self.selectedImage = newValue.first!
        }
    }
}

struct AddEventView: View {
    @State private var name: String = ""
    @State private var emoji: String = "🎉"
    @State private var date: Date = Date()
    @State private var image: UnsplashImage? = nil
    
    @State private var showEmojiOverlay: Bool = false
    
    @ObservedObject var provider: UnsplashResultProvider = .shared
    
    let isEditing: Bool
    let onDismiss: (Event.Properties?) -> Void
    let start: Date?
    
    var allImages: [UnsplashImage] {
        return (self.provider.result?.images ?? []) + UnsplashResult.default.images
    }
    
    init(modifying data: Event.Properties? = nil, _ onDismiss: @escaping (Event.Properties?) -> Void) {
        self.onDismiss = onDismiss
        self.isEditing = data != nil
        
        if let data = data {
            self.start = data.start
            self.name = data.name
            self.emoji = data.emoji
            self.date = data.end
            self.image = data.image
        } else {
            self.start = nil
        }
    }
    
    private func loadRelevantImages(for query: String) {
        var processed = query.filter(by: [.noun, .placeName]).joined(separator: " ")
        if processed.isEmpty {
            processed = query
        }
                
        try? self.provider.fetch(query: processed)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(isEditing ? "Edit Event" : "Create Event").font(.title).bold()
                Spacer()
                Image(systemName: "xmark.circle.fill")
                    .imageScale(.large)
                    .scaleEffect(1.2)
                    .onTapGesture {
                        onDismiss(nil)
                    }
                    .offset(x: 0, y: -1)
            }
            .background(Color.background)
            .padding(.top, 20)
            .padding(.bottom)
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading) {
                    StylizedTextField(
                        text: $name,
                        showEmojiPicker: $showEmojiOverlay,
                        emoji: $emoji
                    ) { startedEditing in
                        if !startedEditing {
                            self.loadRelevantImages(for: name)
                        }
                    } onCommit: {
                        self.loadRelevantImages(for: name)
                        UIApplication.shared.endEditing()
                    }
                    
                    Spacer().height(35)
                    
                    DateView(date: $date)
                    
                    Spacer().height(35)
                    
                    ImagePicker(allImages: allImages, selectedImage: $image)
                    
                    Spacer().height(50)
                    
                    Button {
                        let data = (name: name, start: start ?? Date(), end: date, emoji: emoji, image: image!)
                        
                        if let image = image {
                            self.provider.sendDownloadRequest(for: image)
                        }
                        
                        self.onDismiss(data)
                    } label: {
                        Text(isEditing ? "Apply Changes" : "Create Event")
                    }
                    .buttonStyle(CTAButtonStyle(color: .foreground))
                    .opacity(name.isEmpty ? 0.5 : 1.0)
                    .disabled(name.isEmpty)
                }
            }
        }
        .padding(.horizontal, 20)
        .onAppear {
            if isEditing && !name.isEmpty {
                self.loadRelevantImages(for: name)
            }
        }
        .overlay(
            EmojiOverlay(
                database: EmojiDBProvider.shared.database,
                categories: EmojiDBProvider.categories,
                isPresented: $showEmojiOverlay,
                emoji: $emoji
            )
        )
    }
}

struct AddEventView_Previews: PreviewProvider {
    static var previews: some View {
        AddEventView { _ in}
            .preferredColorScheme(.dark)
    }
}
