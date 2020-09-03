//
//  AddEventView.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-07-25.
//

import SwiftUI
import Combine

extension Sequence where Element: Identifiable {
    /// Returns an array containing all the elements of this Sequence, with no duplicate elements
    func distinct() -> [Element] {
        var set: Set<Element.ID> = []
        return filter { set.insert($0.id).inserted }
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
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
                        .fill(Color.tertiaryBackground)
                        .padding(.vertical, -10)
                )
                .padding(.trailing, 10)
            
            Text(emoji)
                .background(
                    Circle()
                        .fill(Color.tertiaryBackground)
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
    @State private var show: Bool = false

    @Binding var date: Date
    
    let onTimePickerTap: () -> Void
            
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
                .fill(Color.tertiaryBackground)
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
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.tertiaryBackground)
                
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text("Time")
                            .bold()
                            .padding(.leading, 8)
                        
                        DatePicker("Select a Time", selection: $date, displayedComponents: [.hourAndMinute])
                            .labelsHidden()
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .onTapGesture(perform: onTimePickerTap)
                    }
                    .padding(.top, 2)
                    .id("picker")
                    
                    DatePicker("Select a Date", selection: $date, displayedComponents: [.date])
                        .labelsHidden()
                        .datePickerStyle(GraphicalDatePickerStyle())
                }
            }
            .mask(RoundedRectangle(cornerRadius: 10).height(show ? 380 : 0))
        }
    }
}

struct ImagePicker: View {
    let allImages: [BackgroundImage]
    @Binding var selectedImage: BackgroundImage?
    
    @State private var showLocalImagePicker: Bool = false
    @State private var localImageData: Data? = nil
    
    private let rows = [GridItem](repeating: GridItem(.flexible(), spacing: 12), count: 2)
    
    private func imageView(_ image: BackgroundImage) -> some View {
        let overlay = RoundedRectangle(cornerRadius: 11)
            .foregroundColor(Color.foreground.opacity(0.3))
            .overlay(
                Image(systemName: "checkmark.circle.fill")
                    .imageScale(.large)
                    .foregroundColor(.background)
            )
        
        return AsyncImageView(url: image.url(for: .small), color: Color(code: image.color))
            .blur(radius: selectedImage == image ? 2.0 : 0.0)
            .frame(width: 97, height: 97)
            .clipShape(
                RoundedRectangle(cornerRadius: 11)
            )
            .applyIf(selectedImage == image) {
                $0.overlay(overlay)
            }
            .scaleEffect(selectedImage == image ? 0.98 : 1.0)
            .onTapGesture {
                withAnimation(.linear(duration: 0.1)) {
                    self.selectedImage = image
                }
            }
    }
    
    var localImageButton: some View {
        Rectangle()
            .fill(Color.secondaryBackground)
            .overlay(Image(systemName: "photo.on.rectangle.angled").font(.title3))
            .clipShape(
                RoundedRectangle(cornerRadius: 11)
            )
            .onTapGesture {
                showLocalImagePicker = true
            }
            .sheet(isPresented: $showLocalImagePicker) {
                LocalImagePicker(isPresented: $showLocalImagePicker, image: $localImageData)
            }
            .onChange(of: localImageData) { (newValue) in
                guard let data = newValue else {
                    return
                }
                
                let image = BackgroundImage(localImage: data)
                self.selectedImage = image
            }
    }
    
    var body: some View {
        Text("Choose a background")
            .bold()
            .padding(.bottom, 10)
        
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHGrid(rows: rows, spacing: 12) {
                self.localImageButton
                
                ForEach(allImages, content: imageView)
            }
        }
        .height(206)
    }
}

struct AddEventView: View {    
    @State private var name: String = ""
    @State private var emoji: String = "🎉"
    @State private var date: Date = Date()
    @State private var image: BackgroundImage?
    
    @State private var showEmojiOverlay: Bool = false
    
    @StateObject var provider = UnsplashResultProvider()
    
    let onDismiss: (Event?) -> Void
    let props: Event?
    
    func allImages() -> [BackgroundImage] {
        let relatedImages = self.provider.result?.images.map(BackgroundImage.init) ?? []
        
        var images = relatedImages
        
        if let pinnedImage = props?.image {
            if let index = images.firstIndex(of: pinnedImage) {
                images.remove(at: index)
            }
            
            images.prepend(pinnedImage)
        }
        
        images += UnsplashResult.default.images.map(BackgroundImage.init)
        
        if let image = image, !images.contains(image) {
            images.prepend(image)
        }
        
        return images.unique()
    }
    
    var isDisabled: Bool {
        name.isEmpty
    }
    
    init(modifying data: Event? = nil, _ onDismiss: @escaping (Event?) -> Void) {
        self.onDismiss = onDismiss
        self.props = data
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
            Header(props != nil ? "Edit Event" : "Create Event") {
                Image(systemName: "xmark.circle.fill")
                    .onTapGesture { onDismiss(nil) }
            }
            .background(Color.background)
            .padding(.vertical, 20)
//            .padding(.bottom, 5)
            
            ScrollView(showsIndicators: false) {
                ScrollViewReader { (proxy: ScrollViewProxy) in
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
//                        .padding(.top, 5)
                    
                        Spacer().height(35)
                    
                        DateView(date: $date) {
                            proxy.scrollTo("picker", anchor: .top)
                        }
                    
                        Spacer().height(35)
                    
                        ImagePicker(allImages: allImages(), selectedImage: $image)
                        
                        Spacer().height(50)
                    
                        Button {
                            guard let image = image else {
                                return
                            }
                            
                            let data = Event(id: UUID(), name: name, end: date, emoji: emoji, image: image)
                            self.provider.sendDownloadRequest(for: image)
                            
                            self.onDismiss(data)
                        } label: {
                            Text(props != nil ? "Apply Changes" : "Create Event")
                        }
                        .buttonStyle(CTAButtonStyle(color: .foreground))
                        .opacity(isDisabled ? 0.5 : 1.0)
                        .disabled(isDisabled)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .onAppear {
            guard let data = props else { return }
            
            self.name = data.name
            self.emoji = data.emoji
            self.date = data.end
            self.image = data.image
            
            if !name.isEmpty {
                self.loadRelevantImages(for: name)
            }
        }
        .overlay(
            EmojiOverlay(
                isPresented: $showEmojiOverlay,
                emoji: $emoji,
                queue: .main,
                database: EmojiProvider.shared.database
            )
        )
        .onReceive(provider.$result) { result in
            if let first = allImages().first {
                self.image = first
            } else if let first = result?.images.first {
                self.image = BackgroundImage(remoteImage: first)
            }
        }
    }
}

struct AddEventView_Previews: PreviewProvider {
    static var previews: some View {
        AddEventView { _ in }
    }
}

extension Sequence where Element: Hashable {
    /// Returns this sequence with only distinct elements, preserving the original order
    func unique() -> [Element] {
        var seen: Set<Element> = []
        return filter { seen.insert($0).inserted }
    }
}

extension RangeReplaceableCollection {
    mutating func prepend(_ newElement: Element) {
        insert(newElement, at: startIndex)
    }
}
