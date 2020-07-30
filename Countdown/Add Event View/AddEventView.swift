//
//  AddEventView.swift
//  Countdown
//
//  Created by Richard Robinson on 2020-07-25.
//

import SwiftUI

struct CTAButtonStyle: ButtonStyle {
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Font.body.weight(.semibold))
            .foregroundColor(.white)
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
    @Binding var emoji: String
    
    let onCommit: () -> Void
        
    var body: some View {
        Text("What's the occasion?")
            .bold()
            .padding(.bottom, 10)
        
        HStack {
            TextField("New Year's Day", text: $text, onCommit: onCommit)
                .padding(.leading, 10)
                .font(Font.body.weight(.medium))
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.black.opacity(0.05))
                        .padding(.vertical, -10)
            )
            .padding(.trailing, 10)
            
            EmojiPicker(emoji: $emoji)
                .background(
                    Circle()
                        .fill(Color.black.opacity(0.03))
                )
                .width(44)
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
                .fill(Color.black.opacity(0.05))
                .height(40)
            
            Text(formatter.string(from: date))
                .padding(.leading, 10)
                .font(Font.body.weight(.medium))
                .onTapGesture {
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
    
    @State var customImages: [UnsplashImage] = []
    
    let provider: UnsplashResultProvider = .shared
    
    let isEditing: Bool
    let onDismiss: (Event.Properties?) -> Void
    let start: Date?
    
    var allImages: [UnsplashImage] {
        return self.customImages + UnsplashResult.default.results
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
                
        self.provider.fetch(query: processed) { result in
            switch result {
            case .success(let result):
                self.customImages = result.results
                
            case .failure(let error):
                fatalError(error.localizedDescription)
            }
        }
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
            .background(Color.white)
            .padding(.top, 20)
            .padding(.bottom)
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading) {
                    StylizedTextField(text: $name, emoji: $emoji, onCommit: {
                        self.loadRelevantImages(for: name)
                    })
                    
                    Spacer().height(35)
                    
                    DateView(date: $date)

                    Spacer().height(35)
                    
                    ImagePicker(allImages: allImages, selectedImage: $image)
                    
                    Spacer().height(50)

                    Button {
                        let data = (name: name, start: start ?? Date(), end: date, emoji: emoji, image: image!)
                        
                        onDismiss(data)
                    } label: {
                        Text(isEditing ? "Apply Changes" : "Create Event")
                    }
                    .buttonStyle(CTAButtonStyle(color: .black))
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
    }
}

struct AddEventView_Previews: PreviewProvider {
    static var previews: some View {
        AddEventView { _ in}
    }
}
